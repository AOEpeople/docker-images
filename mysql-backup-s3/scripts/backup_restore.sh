#!/bin/bash -e

function echoerr { echo "============================================" 1>&2; echo "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }

echo "Importing s3://${S3_BUCKET}${S3_KEY} to ${DBUSER}:*****@${DBHOST}/${DBNAME}"


echo "Downloading file s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp "s3://${S3_BUCKET}${S3_KEY}" /tmp/dump.sql.gz || error_exit "Failed downloading dump from S3 bucket"

FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then error_exit "Database dump too small ($FILESIZE)"; fi

echo "Importing dump"

echo "SET FOREIGN_KEY_CHECKS=0;" > /tmp/dump.sql

TABLES=$(mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} -e 'show tables' | awk '{ print $1 }' | grep -v '^Tables' )
echo $TABLES;

for t in $TABLES; do
	echo "DROP TABLE IF EXISTS $t;" >> /tmp/dump.sql
done

gunzip -c /tmp/dump.sql.gz | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' >> /tmp/dump.sql
echo "SET FOREIGN_KEY_CHECKS=1;" >> /tmp/dump.sql

cat /tmp/dump.sql | mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} || error_exit "Failed importing database dump"


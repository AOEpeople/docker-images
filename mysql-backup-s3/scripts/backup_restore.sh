#!/bin/bash -e

function echoerr { echo "============================================" 1>&2; echo "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }

echo "Importing s3://${S3_BUCKET}${S3_KEY} to ${DBUSER}:*****@${DBHOST}/${DBNAME}"


echo "Downloading file s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp "s3://${S3_BUCKET}${S3_KEY}" /tmp/dump.sql.gz || error_exit "Failed downloading dump from S3 bucket"

FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then error_exit "Database dump too small ($FILESIZE)"; fi

echo "Disabling foreign key checks"
mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} -e "SET FOREIGN_KEY_CHECKS=0" || error_exit "Failed disabling foreign keys"

echo "Importing dump"
gunzip -c /tmp/dump.sql.gz \
  | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
  | mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} || error_exit "Failed importing database dump"

echo "Enabling foreign key checks"
mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} -e "SET FOREIGN_KEY_CHECKS=1" || error_exit "Failed enabling foreign keys"

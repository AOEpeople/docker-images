#!/bin/bash -e

function echoerr { echo "============================================" 1>&2; echo "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }

echo "Creating dump from ${DBUSER}:*****@${DBHOST}/${DBNAME}"
mysqldump \
   --single-transaction --quick \
   -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} \
   | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
   | gzip > /tmp/dump.sql.gz || error_exit "Failed creating database dump"

FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then error_exit "Database dump too small ($FILESIZE)"; fi

echo "Uploading file to s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp /tmp/dump.sql.gz "s3://${S3_BUCKET}${S3_KEY}" || error_exit "Failed uploading dump to S3"

#!/bin/bash -e

echo "Creating dump from ${DBUSER}:*****@${DBHOST}/${DBNAME}"
mysqldump \
   --single-transaction --quick \
   -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} \
   | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
   | gzip > /tmp/dump.sql.gz

FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then
  echo "Database dump too small ($FILESIZE)"
  exit 1
fi

echo "Uploading file to s3://${S3_BUCKET}${S3_PREFIX}dump.sql.gz"
aws --region "${AWS_DEFAULT_REGION}" s3 cp /tmp/dump.sql.gz "s3://${S3_BUCKET}${S3_KEY}"


export DBUSER=$PIM_DATABASE_USER
export DBNAME=$PIM_DATABASE_NAME
export DBPASSWORD=$PIM_DATABASE_PASSWORD
export DBHOST=$PIM_DATABASE_HOST

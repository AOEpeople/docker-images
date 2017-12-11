#!/bin/bash -e

echo "Downloading file s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp "s3://${S3_BUCKET}${S3_KEY}" /tmp/dump.sql.gz

FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then
  echo "Database dump too small ($FILESIZE)"
  exit 1
fi

echo "Importing dump to ${DBUSER}:*****@${DBHOST}/${DBNAME}"
gunzip -c /tmp/dump.sql.gz \
  | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
  | mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME}

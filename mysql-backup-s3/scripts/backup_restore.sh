#!/bin/bash -e

echo "Downloading file s3://${S3_BUCKET}${S3_PREFIX}dump.sql.gz"
aws --region "${AWS_DEFAULT_REGION}" s3 cp "s3://${S3_BUCKET}${S3_PREFIX}dump.sql.gz" /tmp/dump.sql.gz

echo "Importing dump to ${DBUSER}:*****@${DBHOST}/${DBNAME}"
gunzip -c /tmp/dump.sql.gz | mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME}

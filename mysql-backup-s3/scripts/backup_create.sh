#!/bin/bash -e

  mysqldump -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} | gzip > /tmp/dump.sql.gz && aws --region "${AWS_DEFAULT_REGION}" s3 cp /tmp/dump.sql.gz "s3://${S3_BUCKET}${S3_PREFIX}dump.sql.gz"

#!/bin/bash -e

aws  --region "${AWS_DEFAULT_REGION}" cp "s3://${S3_BUCKET}${S3_PREFIX}dump.sql.gz" /tmp/dump.sql.gz && gunzip -c /tmp/dump.sql.gz | mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME}

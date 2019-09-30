#!/bin/bash -e

# Hotfix
if [ -n "${NAMESPACE:-}" ] ; then S3_KEY=$(echo ${S3_KEY} | sed "s/###NAMESPACE###/${NAMESPACE:-}/g"); fi
if [ -n "${CLUSTER_NAME:-}" ] ; then S3_KEY=$(echo ${S3_KEY} | sed "s/###CLUSTER_NAME###/${CLUSTER_NAME:-}/g"); fi

echo "Downloading file s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp "s3://${S3_BUCKET}${S3_KEY}" /tmp/dump.sql.gz

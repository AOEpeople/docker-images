#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

function echoerr { echo "============================================" 1>&2; echo "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }

if [ -z "${DBUSER}" ] ; then error_exit "DBUSER not set"; fi
if [ -z "${DBPASSWORD}" ] ; then error_exit "DBPASSWORD not set"; fi
if [ -z "${DBHOST}" ] ; then error_exit "DBHOST not set"; fi
if [ -z "${DBNAME}" ] ; then error_exit "DBNAME not set"; fi
if [ -z "${S3_BUCKET}" ] ; then error_exit "S3_BUCKET not set"; fi
if [ -z "${S3_KEY}" ] ; then error_exit "S3_KEY not set"; fi
if [ -z "${DBENGINE}" ] ; then error_exit "DBENGINE not set (mysql or postgres)"; fi

# Hotfix
if [ -n "${NAMESPACE:-}" ] ; then
    S3_KEY=$(echo ${S3_KEY} | sed "s/###NAMESPACE###/${NAMESPACE:-}/g");
    S3_APP_PATH=$(echo ${S3_APP_PATH} | sed "s/###NAMESPACE###/${NAMESPACE:-}/g");
fi
if [ -n "${CLUSTER_NAME:-}" ] ; then
    S3_KEY=$(echo ${S3_KEY} | sed "s/###CLUSTER_NAME###/${CLUSTER_NAME:-}/g");
    S3_APP_PATH=$(echo ${S3_APP_PATH} | sed "s/###CLUSTER_NAME###/${CLUSTER_NAME:-}/g");
fi

if [ -n "${S3_APP_PATH}" ] ; then
    filename="dump.`date +%Y%m%d-%H%M`.sql.gz";
    S3_KEY="${S3_APP_PATH}/${filename}"
else
    filename="dump.sql.gz";
fi


echo "Creating ${DBENGINE} dump from ${DBUSER}:*****@${DBHOST}/${DBNAME}"
if [ "${DBENGINE}" == "mysql" ] ; then

    # required for sed
    export LANG=C
    export LC_CTYPE=C
    export LC_ALL=C

    mysqldump \
       --max-allowed-packet=8388608 \
       --verbose \
       --routines \
       --single-transaction --quick \
       --set-gtid-purged=OFF \
       -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} \
       | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
       | sed -e 's/DEFINER[ ]*=[ ]*[^*]*PROCEDURE/PROCEDURE/' \
       | sed -e 's/DEFINER[ ]*=[ ]*[^*]*FUNCTION/FUNCTION/' \
       | gzip > "/tmp/${filename}" || error_exit "Failed creating database dump"
elif [ "${DBENGINE}" == "postgres" ] ; then
    export PGPASSWORD="$DBPASSWORD"
    pg_dump \
        --format=p \
        --no-owner \
        --clean \
        --username=${DBUSER} \
        --host=${DBHOST} \
        --dbname=${DBNAME} | gzip > "/tmp/${filename}" || error_exit "Failed creating database dump"
else
    error_exit "DBENGINE ${DBENGINE} is not supported"
fi


FILESIZE=$(stat -c%s "/tmp/${filename}")

if [ "$FILESIZE" -lt "1000" ] ; then error_exit "Database dump too small ($FILESIZE)"; fi

echo "Uploading file to s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" \
    s3api put-object \
    --bucket "${S3_BUCKET}" \
    --key "${S3_KEY}" \
    --body "/tmp/${filename}" \
    --tagging 'one_week_expiration=true' \
    || error_exit "Failed uploading dump to S3"

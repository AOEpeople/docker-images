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

echo "Creating ${DBENGINE} dump from ${DBUSER}:*****@${DBHOST}/${DBNAME}"
if [ "${DBENGINE}" == "mysql" ] ; then

    # required for sed
    export LANG=C
    export LC_CTYPE=C
    export LC_ALL=C

    mysqldump \
       --routines \
       --single-transaction --quick \
       --set-gtid-purged=OFF \
       -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} \
       | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
       | sed -e 's/DEFINER[ ]*=[ ]*[^*]*PROCEDURE/PROCEDURE/' \
       | sed -e 's/DEFINER[ ]*=[ ]*[^*]*FUNCTION/FUNCTION/' \
       | gzip > /tmp/dump.sql.gz || error_exit "Failed creating database dump"
elif [ "${DBENGINE}" == "postgres" ] ; then
    export PGPASSWORD="$DBPASSWORD"
    pg_dump \
        --format=p \
        --no-owner \
        --clean \
        --username=${DBUSER} \
        --host=${DBHOST} \
        --dbname=${DBNAME} | gzip > /tmp/dump.sql.gz || error_exit "Failed creating database dump"
else
    error_exit "DBENGINE ${DBENGINE} is not supported"
fi


FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then error_exit "Database dump too small ($FILESIZE)"; fi

echo "Uploading file to s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp /tmp/dump.sql.gz "s3://${S3_BUCKET}${S3_KEY}" || error_exit "Failed uploading dump to S3"

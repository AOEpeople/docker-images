#!/bin/bash -e

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function echoerr { echo "============================================" 1>&2; echo "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }

if [ -z "${DBUSER}" ] ; then error_exit "DBUSER not set"; fi
if [ -z "${DBPASSWORD}" ] ; then error_exit "DBPASSWORD not set"; fi
if [ -z "${DBHOST}" ] ; then error_exit "DBHOST not set"; fi
if [ -z "${DBNAME}" ] ; then error_exit "DBNAME not set"; fi
if [ -z "${S3_BUCKET}" ] ; then error_exit "S3_BUCKET not set"; fi
if [ -z "${S3_KEY}" ] ; then error_exit "S3_KEY not set"; fi
if [ -z "${DBENGINE}" ] ; then error_exit "DBENGINE not set (mysql or postgres)"; fi


echo "Importing s3://${S3_BUCKET}${S3_KEY} to ${DBUSER}:*****@${DBHOST}/${DBNAME} (${DBENGINE})"


echo "Downloading file s3://${S3_BUCKET}${S3_KEY}"
aws --region "${AWS_DEFAULT_REGION}" s3 cp "s3://${S3_BUCKET}${S3_KEY}" /tmp/dump.sql.gz || error_exit "Failed downloading dump from S3 bucket"

FILESIZE=$(stat -c%s "/tmp/dump.sql.gz")

if [ "$FILESIZE" -lt "1000" ] ; then error_exit "Database dump too small ($FILESIZE)"; fi

echo "Importing dump"

if [[ "${DBENGINE}" = "mysql" ]] ; then

    echo "Starting MySQL import"

    echo "Dropping all tables first"
    mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} < ${SOURCE_DIR}/mysql_drop_all_tables.sql

    echo "Unzipping dump.sql.gz..."
    echo "SET FOREIGN_KEY_CHECKS=0;" > /tmp/dump.sql
    gunzip -c /tmp/dump.sql.gz \
        | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' \
        | fgrep -v GLOBAL.GTID_PURGED \
        | fgrep -v SESSION.SQL_LOG_BIN >> /tmp/dump.sql
    echo "SET FOREIGN_KEY_CHECKS=1;" >> /tmp/dump.sql

    mysql -u${DBUSER} -p${DBPASSWORD} -h${DBHOST} ${DBNAME} < /tmp/dump.sql || error_exit "Failed importing database dump"

elif [[ "${DBENGINE}" = "postgres" ]] ; then

    echo "Starting Postgres import"
    export PGPASSWORD="$DBPASSWORD"

    echo "Dropping all tables first"
    psql --username=${DBUSER} --host=${DBHOST} --dbname=${DBNAME} -f ${SOURCE_DIR}/postgres_drop_all_tables.sql

    echo "Importing dump"
    gunzip -c /tmp/dump.sql.gz | psql --username=${DBUSER} --host=${DBHOST} --dbname=${DBNAME}  || error_exit "Failed importing database dump"

else
    error_exit "DBENGINE ${DBENGINE} is not supported"
fi


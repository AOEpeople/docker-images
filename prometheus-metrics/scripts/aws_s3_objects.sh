#!/usr/bin/env bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

color_normal="\033[0m"; color_red="\033[0;31m"; color_green="\033[0;32m"; color_yellow="\033[0;34m";
function echoerr { echo "============================================" 1>&2; echo_red "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }
function echo_green { echo -e "${color_green}$1${color_normal}"; }
function echo_red { echo -e "${color_red}$1${color_normal}"; }
function echo_yellow { echo -e "${color_yellow}$1${color_normal}"; }

if [ -z "${AWS_BUCKET_NAME}" ] ; then error_exit "AWS_BUCKET_NAME not set"; fi
if [ -z "${AWS_DEFAULT_REGION}" ] ; then error_exit "AWS_DEFAULT_REGION not set"; fi
if [ -z "${PROM_PUSHGATEWAY_URL}" ] ; then error_exit "PROM_PUSHGATEWAY_URL not set"; fi
if [ -z "${PROM_PUSHGATEWAY_PORT}" ] ; then PROM_PUSHGATEWAY_PORT=9091; fi

NOW=`date +%s`

# https://github.com/prometheus/pushgateway#url
COMPLETE_PROM_PUSHGATEWAY_URL="${PROM_PUSHGATEWAY_URL}:${PROM_PUSHGATEWAY_PORT}/metrics/job/aws_s3_objects" # /metrics/job/<JOBNAME>{/<LABEL_NAME>/<LABEL_VALUE>}

if [ "${PROCCESS_ONLY_LATEST_OBJECT_IN_PATH}" == "1" ] ; then 
    s3list=`aws --region "${AWS_DEFAULT_REGION}" s3 ls s3://"${AWS_BUCKET_NAME}${AWS_BUCKET_PATH}" --recursive | sort | tail -n 1 | awk '{print $4}'` || error_exit "Failed list bucket"
else 
    s3list=`aws --region "${AWS_DEFAULT_REGION}" s3 ls s3://"${AWS_BUCKET_NAME}${AWS_BUCKET_PATH}" --recursive | sort | awk '{print $4}'` || error_exit "Failed list bucket"
fi

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT

for KEY in $s3list
do
    echo
    echo ">> AWS_BUCKET_NAME: ${AWS_BUCKET_NAME}"
    echo ">> KEY: ${KEY}"

    OBJECT_META_DATA=$(aws --region "${AWS_DEFAULT_REGION}" s3api head-object --bucket "${AWS_BUCKET_NAME}" --key "${KEY}") || error_exit "Failed fetch object head"
    OBJECT_SIZE=$(echo $OBJECT_META_DATA | jq -r '.ContentLength') || error_exit "Failed to get ContentLenght via jq" # Size of the body in bytes
    LAST_MODIFIED_RAW=$(echo $OBJECT_META_DATA | jq -r '.LastModified') || error_exit "Failed to get LastModified via jq" # Last modified date of the object (timestamp)
    LAST_MODIFIED=$(date -d "${LAST_MODIFIED_RAW}" +"%s") || error_exit "Failed to parse LastModified to unix timestamp" # Convert "Thu, 18 Jan 2018 09:00:16 GMT" to UNIX timestamp (just work on linux!!)
    AGE=$(expr $NOW - $LAST_MODIFIED) # seconds

    echo ">> OBJECT_SIZE: $(printf %s\\n ${OBJECT_SIZE} | numfmt --to=si) (${OBJECT_SIZE} bytes)"
    echo ">> LAST_MODIFIED: ${LAST_MODIFIED_RAW} (timestamp: ${LAST_MODIFIED})"
    echo ">> AGE: ${AGE} (seconds)"

    echo -e "aws_s3_object_key_age{bucket=\"${AWS_BUCKET_NAME}\", key=\"${KEY}\", last_modified=\"${LAST_MODIFIED_RAW}\"} ${AGE}" >> $TMPDIR/metrics.txt
    echo -e "aws_s3_object_key_size{bucket=\"${AWS_BUCKET_NAME}\", key=\"${KEY}\", last_modified=\"${LAST_MODIFIED_RAW}\"} ${OBJECT_SIZE}" >> $TMPDIR/metrics.txt
done
echo

cat $TMPDIR/metrics.txt | curl -s --data-binary @- ${COMPLETE_PROM_PUSHGATEWAY_URL} || error_exit "Failed to push to ${COMPLETE_PROM_PUSHGATEWAY_URL}"
echo_green "Pushed successfully to ${COMPLETE_PROM_PUSHGATEWAY_URL}"
echo_green "Done"
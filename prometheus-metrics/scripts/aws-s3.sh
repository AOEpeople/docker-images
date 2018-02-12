#!/bin/bash -e

#
# Example
# docker run -d -p 9091:9091 prom/pushgateway
# docker run --rm -i -e DEBUG=1 -e PROM_PUSHGATEWAY_URL="http://127.0.0.1" -e AWS_ACCESS_KEY_ID="xxx" -e AWS_SECRET_ACCESS_KEY="xxx" -e AWS_BUCKET_NAME="backup.om3.cloud" -e AWS_DEFAULT_REGION="eu-central-1" aoepeople/prometheus-metrics:0.4 /bin/bash -c "/usr/local/bin/aws-s3.sh"
#


function echoerr {
    echo_red "============================================" 1>&2;
    echo_red "ERROR: $@" 1>&2;
    echo_red "============================================" 1>&2;
}

function error_exit { echoerr "$1"; exit 1; }
function echo_green { echo -e "\033[0;32m$1\033[0m"; }
function echo_red { echo -e "\033[0;31m$1\033[0m"; }

if [ -z "${AWS_BUCKET_NAME}" ] ; then error_exit "AWS_BUCKET_NAME not set"; fi
if [ -z "${AWS_DEFAULT_REGION}" ] ; then error_exit "AWS_DEFAULT_REGION not set"; fi
if [ -z "${PROM_PUSHGATEWAY_URL}" ] ; then error_exit "PROM_PUSHGATEWAY_URL not set"; fi
if [ -z "${PROM_PUSHGATEWAY_PORT}" ] ; then PROM_PUSHGATEWAY_PORT=9091; fi

NOW=`date +%s`

# https://github.com/prometheus/pushgateway#url
COMPLETE_PROM_PUSHGATEWAY_URL="${PROM_PUSHGATEWAY_URL}:${PROM_PUSHGATEWAY_PORT}/metrics/job/s3_objects" # /metrics/job/<JOBNAME>{/<LABEL_NAME>/<LABEL_VALUE>}

if [ "${DEBUG}" == "1" ]; then
    echo 
    echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}"
    echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}"
    echo "AWS_BUCKET_NAME: ${AWS_BUCKET_NAME}"
    echo "AWS_BUCKET_PATH: ${AWS_BUCKET_PATH}"
    echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"
    echo "PROM_PUSHGATEWAY_URL: ${PROM_PUSHGATEWAY_URL}"
    echo "PROM_PUSHGATEWAY_PORT: ${PROM_PUSHGATEWAY_PORT}"
    echo "COMPLETE_PROM_PUSHGATEWAY_URL: ${COMPLETE_PROM_PUSHGATEWAY_URL}"
    echo "NOW: ${NOW}"
    echo 
fi 

if [ "${PROCCESS_ONLY_LATEST_OBJECT_IN_PATH}" == "1" ] ; then 
    echo "> aws --region \"${AWS_DEFAULT_REGION}\" s3 ls s3://\"${AWS_BUCKET_NAME}${AWS_BUCKET_PATH}\" --recursive | sort | tail -n 1 | awk '{print $4}'"
    s3list=`aws --region "${AWS_DEFAULT_REGION}" s3 ls s3://"${AWS_BUCKET_NAME}${AWS_BUCKET_PATH}" --recursive | sort | tail -n 1 | awk '{print $4}'` || error_exit "Failed list bucket"
else 
    echo "> aws --region \"${AWS_DEFAULT_REGION}\" s3 ls s3://\"${AWS_BUCKET_NAME}${AWS_BUCKET_PATH}\" --recursive | sort | awk '{print $4}'"
    s3list=`aws --region "${AWS_DEFAULT_REGION}" s3 ls s3://"${AWS_BUCKET_NAME}${AWS_BUCKET_PATH}" --recursive | sort | awk '{print $4}'` || error_exit "Failed list bucket"
fi

for key in $s3list
do
    if [ "${DEBUG}" == "1" ]; then
        echo 
        echo ">> KEY: ${key}" 
    fi

    OBJECT_META_DATA=$(aws --region "${AWS_DEFAULT_REGION}" s3api head-object --bucket "${AWS_BUCKET_NAME}" --key "${key}") || error_exit "Failed fetch object head"
    OBJECT_SIZE=$(echo $OBJECT_META_DATA | jq -r '.ContentLength') || error_exit "Failed to get ContentLenght via jq" # Size of the body in bytes
    LAST_MODIFIED_RAW=$(echo $OBJECT_META_DATA | jq -r '.LastModified') || error_exit "Failed to get LastModified via jq" # Last modified date of the object (timestamp)
    LAST_MODIFIED=$(date -d "${LAST_MODIFIED_RAW}" +"%s") || error_exit "Failed to parse LastModified to unix timestamp" # Convert "Thu, 18 Jan 2018 09:00:16 GMT" to UNIX timestamp (just work on linux!!)
    AGE=$(expr $NOW - $LAST_MODIFIED) # seconds

    if [ "${DEBUG}" == "1" ]; then
        echo ">> OBJECT_SIZE: ${OBJECT_SIZE}"
        echo ">> LAST_MODIFIED: ${LAST_MODIFIED_RAW} (timestamp: ${LAST_MODIFIED})"
        echo ">> AGE: ${AGE} (seconds)"
    fi


    cat <<EOF | curl --data-binary @- ${COMPLETE_PROM_PUSHGATEWAY_URL}
s3_key_age{bucket="${AWS_BUCKET_NAME}", key="${key}"} ${AGE}
s3_key_size{bucket="${AWS_BUCKET_NAME}", key="${key}"} ${OBJECT_SIZE}
EOF

echo "Done"
done
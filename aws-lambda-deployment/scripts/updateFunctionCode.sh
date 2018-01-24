#!/bin/bash -e

function echoerr {
    echo_red "============================================" 1>&2;
    echo_red "ERROR: $@" 1>&2;
    echo_red "============================================" 1>&2;
}

function error_exit { echoerr "$1"; exit 1; }
function echo_green { echo -e "\033[0;32m$1\033[0m"; }
function echo_red { echo -e "\033[0;31m$1\033[0m"; }

if [ -z "${VERSION_NUMBER}" ] ; then error_exit "VERSION_NUMBER not set"; fi
if [ -z "${ARTIFACT_URL}" ] ; then error_exit "ARTIFACT_URL not set"; fi
if [ -z "${AWS_BUCKET_NAME}" ] ; then error_exit "AWS_BUCKET_NAME not set"; fi
if [ -z "${AWS_REGION}" ] ; then error_exit "AWS_REGION not set"; fi
if [ -z "${AWS_LAMBDA_ARTIFACT_NAME}" ] ; then error_exit "AWS_LAMBDA_ARTIFACT_NAME not set"; fi
if [ -z "${AWS_LAMBDA_FUNCTION}" ] ; then error_exit "AWS_LAMBDA_FUNCTION not set"; fi

ARTIFACT_URL=${ARTIFACT_URL//###VERSION_NUMBER###/$VERSION_NUMBER}
AWS_LAMBDA_ARTIFACT_NAME=${AWS_LAMBDA_ARTIFACT_NAME//###VERSION_NUMBER###/$VERSION_NUMBER}

if [ "${STAGE_NAME}" != "" ] ; then
    ARTIFACT_URL=${ARTIFACT_URL//###STAGE_NAME###/$STAGE_NAME}
    AWS_BUCKET_NAME=${AWS_BUCKET_NAME//###STAGE_NAME###/$STAGE_NAME}
    AWS_LAMBDA_ARTIFACT_NAME=${AWS_LAMBDA_ARTIFACT_NAME//###STAGE_NAME###/$STAGE_NAME}
    AWS_LAMBDA_FUNCTION=${AWS_LAMBDA_FUNCTION//###STAGE_NAME###/$STAGE_NAME}
fi

CURL_CREDENTIALS=""
if [ "${USERNAME}" != "" ] && [ "${PASSWORD}" != "" ] ; then CURL_CREDENTIALS="-u ${USERNAME}:${PASSWORD}"; fi

if [ "${DEBUG}" == "1" ]; then
    echo 
    echo "VERSION_NUMBER: ${VERSION_NUMBER}"
    echo "ARTIFACT_URL: ${ARTIFACT_URL}"
    echo "USERNAME: ${USERNAME}"
    echo "CURL_CREDENTIALS: ${CURL_CREDENTIALS}"
    echo "AWS_BUCKET_NAME: ${AWS_BUCKET_NAME}"
    echo "AWS_REGION: ${AWS_REGION}"
    echo "AWS_LAMBDA_ARTIFACT_NAME: ${AWS_LAMBDA_ARTIFACT_NAME}"
    echo "AWS_LAMBDA_FUNCTION: ${AWS_LAMBDA_FUNCTION}"
    echo 
fi 

curl $CURL_CREDENTIALS -O $ARTIFACT_URL || error_exit "Failed to download lambda artifact (${ARTIFACT_URL})"
aws s3 cp $AWS_LAMBDA_ARTIFACT_NAME s3://$AWS_BUCKET_NAME/$AWS_LAMBDA_ARTIFACT_NAME || error_exit "Failed to upload ${AWS_LAMBDA_ARTIFACT_NAME} to s3 bucket ${AWS_BUCKET_NAME}"
aws --region $AWS_REGION lambda update-function-code --function-name $AWS_LAMBDA_FUNCTION --s3-key $AWS_LAMBDA_ARTIFACT_NAME --s3-bucket $AWS_BUCKET_NAME || error_exit "Failed to update lambda function"
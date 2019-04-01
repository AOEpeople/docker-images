#!/usr/bin/env bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

color_normal="\033[0m"; color_red="\033[0;31m"; color_green="\033[0;32m"; color_yellow="\033[0;34m";
function echoerr { echo "============================================" 1>&2; echo_red "ERROR: $*" 1>&2;  echo "============================================" 1>&2; }
function error_exit { echoerr "$1"; exit 1; }
function echo_green { echo -e "${color_green}$1${color_normal}"; }
function echo_red { echo -e "${color_red}$1${color_normal}"; }
function echo_yellow { echo -e "${color_yellow}$1${color_normal}"; }

if [ -z "${PROM_PUSHGATEWAY_URL}" ] ; then error_exit "PROM_PUSHGATEWAY_URL not set"; fi
if [ -z "${PROM_PUSHGATEWAY_PORT}" ] ; then PROM_PUSHGATEWAY_PORT=9091; fi
if [ -z "${AWS_DEFAULT_REGION}" ] ; then error_exit "AWS_DEFAULT_REGION not set"; fi

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT

REGIONS="${AWS_DEFAULT_REGION} us-east-1"
for REGION in ${REGIONS}; do
    CERTIFICATES=$(aws --region "${REGION}" acm list-certificates --certificate-statuses ISSUED) || error_exit "Failed to get certificates"
    for CERTIFICATE in $(echo "${CERTIFICATES}"  | jq -r '.CertificateSummaryList[] | @base64'); do
        _jq() {
            echo ${CERTIFICATE} | base64 --decode | jq -r ${1} || error_exit "Failed to decode jq result"
        }

        DOMAIN=$(_jq '.DomainName')
        ARN=$(_jq '.CertificateArn')
        CERTIFICATION_DATA=$(aws --region "${REGION}" acm describe-certificate --certificate-arn "${ARN}") || error_exit "Failed to get certification data"
        RENEWAL_ELIGIBILITY=$(echo ${CERTIFICATION_DATA} | jq -r '.Certificate.RenewalEligibility')

        # The time after which the certificate is not valid. Type: Timestamp https://docs.aws.amazon.com/acm/latest/APIReference/API_CertificateDetail.html#ACM-Type-CertificateDetail-NotAfter
        NO_AFTER=$(echo ${CERTIFICATION_DATA} | jq -r '.Certificate.NotAfter')
        HUMAN_READABLE_EXPIRE_DATE=$(date -d @${NO_AFTER})
        EXPIRES_IN_DAYS=$(( ($(date +%s --date "@${NO_AFTER}") - $(date +%s)) / (3600*24) ))
        IDENTIFIER=$(echo -n "${ARN}" | md5sum | awk '{print $1}') || error_exit "Failed to generate identifier"
        #echo_yellow "Certification of domain \"${DOMAIN}\" expires in ${EXPIRES_IN_DAYS} days (${HUMAN_READABLE_EXPIRE_DATE})"
        echo -e "aws_acm_ssl_certificate_expiration{domain=\"${DOMAIN}\", region=\"${REGION}\", renewal_eligibility=\"${RENEWAL_ELIGIBILITY}\", arn=\"${ARN}\"} ${EXPIRES_IN_DAYS}" >> $TMPDIR/metrics.txt
    done

    ENDPOINT="${PROM_PUSHGATEWAY_URL}:${PROM_PUSHGATEWAY_PORT}/metrics/job/aws_acm_ssl_certificates"
    cat $TMPDIR/metrics.txt | curl -s --data-binary @- ${ENDPOINT} || error_exit "Failed to push to ${ENDPOINT}"
done
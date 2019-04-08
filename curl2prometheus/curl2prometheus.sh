#!/usr/bin/env bash

# URLS="http://www.google.de http://www.facebook.com http://ssdsdsdsd|type=internal,group=healthcheck"
# PUSH_DESTINATION="http://pushgateway.example.org:9091/metrics/job/curl"

if [ -z "$URLS" ] ; then echo "No URLS given"; exit 1; fi
if [ -z "$PUSH_DESTINATION" ] ; then echo "No PUSH_DESTINATION given"; exit 1; fi

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT

COUNTER=0

for DEFINITION in $URLS; do

if [[ "$DEFINITION" != http* ]] ; then
    echo "Skipping $DEFINITION because it doesn't start with http"
    continue
fi

IFS='|' read -a PIECES <<< "${DEFINITION}"
URL=${PIECES[0]}

# parse additional attributes
ADDITIONAL_ATTRIBUTES=${PIECES[1]}
ADDITIONAL_ATTRIBUTES=${ADDITIONAL_ATTRIBUTES%,}
ADDITIONAL_ATTRIBUTES=${ADDITIONAL_ATTRIBUTES#,}
if [ ! -z "${ADDITIONAL_ATTRIBUTES}" ] ; then
    ADDITIONAL_ATTRIBUTES="${ADDITIONAL_ATTRIBUTES},"
fi

if [ ! -z "${GLOBAL_ATTRIBUTES}" ] ; then
    GLOBAL_ATTRIBUTES=${GLOBAL_ATTRIBUTES%,}
    GLOBAL_ATTRIBUTES=${GLOBAL_ATTRIBUTES#,}
    GLOBAL_ATTRIBUTES="${GLOBAL_ATTRIBUTES},"
fi

if [ ! -z "${AUTH_HEADER_VALUE}" ] ; then
    if [ -z "${AUTH_HEADER_NAME}" ] ; then
        AUTH_HEADER_NAME="Authorization"
    fi
    AUTH_HEADER="${AUTH_HEADER_NAME}: ${AUTH_HEADER_VALUE}"
else
    AUTH_HEADER=""
fi

ATTRIBUTES="${GLOBAL_ATTRIBUTES}${ADDITIONAL_ATTRIBUTES}url=\"${URL}\""

# Output format
read -r -d '' OUTPUT << EOM
curl_time_namelookup{${ATTRIBUTES},code="%{http_code}"} %{time_namelookup}
curl_time_connect{${ATTRIBUTES},code="%{http_code}"} %{time_connect}
curl_time_appconnect{${ATTRIBUTES},code="%{http_code}"} %{time_appconnect}
curl_time_pretransfer{${ATTRIBUTES},code="%{http_code}"} %{time_pretransfer}
curl_time_starttransfer{${ATTRIBUTES},code="%{http_code}"} %{time_starttransfer}
curl_time_total{${ATTRIBUTES},code="%{http_code}"} %{time_total}
curl_http_code{${ATTRIBUTES}} %{http_code}
EOM

# do the curl call
echo "Curl: ${URL}"
curl --max-time 30 \
    --silent \
    --header 'Cache-Control: no-cache' \
    --header "${AUTH_HEADER}" \
    --write-out "$OUTPUT\n" --output /dev/null \
    ${URL} > $TMPDIR/$COUNTER.metrics &

let COUNTER++
done

wait

# debug output
echo "Metrics:"
cat $TMPDIR/*.metrics

# push all metrics to push gateway
echo ""
echo "Pushing metrics to $PUSH_DESTINATION"
cat $TMPDIR/*.metrics | curl --data-binary @- "$PUSH_DESTINATION"

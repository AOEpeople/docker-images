#!/usr/bin/env bash

# URLS="http://www.google.de http://www.facebook.com http://ssdsdsdsd"
# PUSH_DESTINATION="http://pushgateway.example.org:9091/metrics/job/curl"

if [ -z "$URLS" ] ; then echo "No URLS given"; exit 1; fi
if [ -z "$PUSH_DESTINATION" ] ; then echo "No PUSH_DESTINATION given"; exit 1; fi

TMPDIR=$(mktemp -d)
trap "rm -rf ${TMPDIR}" EXIT

COUNTER=0

for URL in $URLS; do

# Output format
read -r -d '' OUTPUT << EOM
curl_time_namelookup{url=$URL} %{time_namelookup}
curl_time_connect{url=$URL} %{time_connect}
curl_time_appconnect{url=$URL} %{time_appconnect}
curl_time_namelookup{url=$URL} %{time_namelookup}
curl_time_namelookup{url=$URL} %{time_namelookup}
curl_time_total{url=$URL} %{time_total}
curl_http_code{url=$URL} %{http_code}
EOM

# do the curl call
curl -s -w "$OUTPUT\n" -o /dev/null -s $URL > $TMPDIR/$COUNTER.metrics

let COUNTER++
done

# debug output
cat $TMPDIR/*.metrics

# push all metrics to push gateway
cat $TMPDIR/*.metrics | curl -s --data-binary @- "$PUSH_DESTINATION"

#!/usr/bin/env bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while true ; do
    sleep ${SLEEP:-60}
    /bin/bash ${SOURCE_DIR}/curl2prometheus.sh
done

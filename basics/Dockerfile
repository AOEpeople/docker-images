FROM ubuntu:trusty

RUN apt-get update \
    && apt-get install -y build-essential curl git jq python2.7 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists
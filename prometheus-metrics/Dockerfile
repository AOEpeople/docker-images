FROM ubuntu:18.10
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y python-pip curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade setuptools && \
    pip install awscli && \
    rm -rf /tmp/pip_build_root && \
    aws --version && \
    chmod +x /usr/local/bin/*

COPY ./scripts/* /usr/local/bin/
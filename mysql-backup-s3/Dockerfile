FROM debian:jessie

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -y python-pip mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install awscli && \
    rm -rf /tmp/pip_build_root && \
    aws --version

COPY ./scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

CMD ["backup_create.sh"]

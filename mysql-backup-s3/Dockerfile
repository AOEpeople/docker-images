FROM ubuntu:18.10

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -y python-pip mysql-client postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade setuptools && \
    pip install awscli && \
    rm -rf /tmp/pip_build_root && \
    aws --version

COPY ./scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

CMD ["backup_create.sh"]

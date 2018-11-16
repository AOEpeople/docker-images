FROM python:3.7

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -y python-pip vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install awscli && \
    rm -rf /tmp/pip_build_root && \
    aws --version && \
    chmod +x /usr/local/bin/*

RUN pip install boto3 requests requests_aws4auth

COPY ./scripts/* /

ENTRYPOINT ["python", "/snapshot.py"]
CMD ["create"]
# Prometheus Metrics

## Requirements

- Prometheus Push Gateway

## AWS S3 Metrics

Job: `s3_objects`
Metrics: 
`s3_key_age{bucket="<AWS_BUCKET_NAME>", key="<KEY>"} <AGE_IN_SECONDS>`
`s3_key_size{bucket="<AWS_BUCKET_NAME>", key="<KEY>"} <OBJECT_SIZE_IN_BYTES>`


**Example command:**

```
docker run --rm -i \
  -e DEBUG=1 \
  -e PROM_PUSHGATEWAY_URL="http://prometheus-push-gateway-url" \
  -e PROM_PUSHGATEWAY_PORT="9091" \
  -e AWS_ACCESS_KEY_ID="XYZ" \
  -e AWS_SECRET_ACCESS_KEY="XXYYZZ" \
  -e AWS_BUCKET_NAME="backup.om3.cloud" \
  -e AWS_REGION="eu-central-1" \
  aoepeople/prometheus-metrics:0.1 /bin/bash -c "/usr/local/bin/aws-s3.sh"
```
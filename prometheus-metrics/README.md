# Prometheus Metrics

## Requirements

- Prometheus Push Gateway

## AWS ACM SSL Certificate Expiration

Job: 
```
aws_acm_ssl_certificates
```

Metrics: 
```
aws_acm_ssl_certificate_expiration{domain="${DOMAIN}", renewal_eligibility="${RENEWAL_ELIGIBILITY}", arn="${ARN}"}
```

**Example command within kubernetes cluster:**

```
vuku k run check-acm-certificates --rm -it \
    --env PROM_PUSHGATEWAY_URL="http://prometheus-pushgateway.k28s-infrastructure" \
    --env AWS_DEFAULT_REGION="eu-central-1" \
    --image=aoepeople/prometheus-metrics:latest -- /bin/bash -c "/usr/local/bin/check_acm_certificates.sh"
vuku k run check-acm-certificates --rm -it \
    --env PROM_PUSHGATEWAY_URL="http://prometheus-pushgateway.k28s-infrastructure" \
    --env AWS_DEFAULT_REGION="eu-central-1" \
    --image=aoepeople/prometheus-metrics:latest -- /bin/bash 
```

**Example command within localhost:**

```
cd prometheus-metrics/
docker run -d -p 9091:9091 --name prom_pushgateway prom/pushgateway
export PROM_PUSHGATEWAY_HOST=$(docker exec $(docker ps -f name=prom_pushgateway --format "{{.ID}}") hostname -i)
export AWS_PROFILE=om3-lhr-prod
export AWS_DEFAULT_REGION=$(aws configure get region --profile ${AWS_PROFILE})
docker run --rm -i -v $(PWD):/app -v $HOME/.aws:/root/.aws -w /app -e AWS_PROFILE="${AWS_PROFILE}" -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" -e PROM_PUSHGATEWAY_URL="http://${PROM_PUSHGATEWAY_HOST}" aoepeople/k8s_tools /bin/bash -c "/app/scripts/check_acm_certificates.sh"

```

### Required persmissions

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "acm:ListCertificates",
        "acm:describe-certificate"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
```







## AWS S3 Metrics

Job: 
```
s3_objects
```

Metrics: 
```
s3_key_age{bucket="<AWS_BUCKET_NAME>", key="<KEY>"} <AGE_IN_SECONDS>
s3_key_size{bucket="<AWS_BUCKET_NAME>", key="<KEY>"} <OBJECT_SIZE_IN_BYTES>
```

**Example command:**

```
docker run --rm -i \
  -e DEBUG=1 \
  -e PROM_PUSHGATEWAY_URL="http://prometheus-push-gateway-url" \
  -e PROM_PUSHGATEWAY_PORT="9091" \
  -e AWS_ACCESS_KEY_ID="XYZ" \
  -e AWS_SECRET_ACCESS_KEY="XXYYZZ" \
  -e AWS_BUCKET_NAME="backup.om3.cloud" \
  -e AWS_DEFAULT_REGION="eu-central-1" \
  aoepeople/prometheus-metrics:0.1 /bin/bash -c "/usr/local/bin/aws_s3_objects.sh"
```


### Required persmissions

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListObjects"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::<bucket_name>/<key_name>",
      "Principal": "*"
    }
  ]
}
```
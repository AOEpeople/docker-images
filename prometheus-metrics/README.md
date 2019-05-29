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
```

**Example command within localhost:**

```
cd prometheus-metrics/
docker run -d -p 9091:9091 --name prom_pushgateway prom/pushgateway
export PROM_PUSHGATEWAY_HOST=$(docker exec $(docker ps -f name=prom_pushgateway --format "{{.ID}}") hostname -i)
export AWS_PROFILE=om3-lhr-prod
export AWS_DEFAULT_REGION=$(aws configure get region --profile ${AWS_PROFILE})
docker run --rm -i -v $(PWD):/app -v $HOME/.aws:/root/.aws -w /app -e AWS_PROFILE="${AWS_PROFILE}" -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" -e PROM_PUSHGATEWAY_URL="http://${PROM_PUSHGATEWAY_HOST}" aoepeople/k8s_tools /bin/bash -c "/app/scripts/aws_acm_ssl_certificates.sh"

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
aws_s3_objects
```

Metrics: 
```
aws_s3_object_key_age{bucket="<AWS_BUCKET_NAME>", key="<KEY>", last_modified="<LAST_MODIFIED>"} <AGE_IN_SECONDS>
aws_s3_object_key_size{bucket="<AWS_BUCKET_NAME>", key="<KEY>", last_modified="<LAST_MODIFIED>"} <OBJECT_SIZE_IN_BYTES>
```

**Example command within kubernetes cluster:**

```
vuku k run check-s3-objects --rm -it \
    --env PROM_PUSHGATEWAY_URL="http://prometheus-pushgateway.k28s-infrastructure" \
    --env AWS_ACCESS_KEY_ID="OM3_META_ACCESS_KEY_ID" \
    --env AWS_SECRET_ACCESS_KEY="OM3_META_SECRET_ACCESS_KEY" \
    --env AWS_BUCKET_NAME="backup.om3.cloud" \
    --env AWS_BUCKET_PATH="/backups/PROJECT/rds/STAGE" \
    --env AWS_DEFAULT_REGION="eu-central-1" \
    --image=aoepeople/prometheus-metrics:latest -- /bin/bash -c "/usr/local/bin/aws_s3_objects.sh"
```

**Example command within localhost:**

```
cd prometheus-metrics/
docker run -d -p 9091:9091 --name prom_pushgateway prom/pushgateway
export PROM_PUSHGATEWAY_HOST=$(docker exec $(docker ps -f name=prom_pushgateway --format "{{.ID}}") hostname -i)
export AWS_PROFILE=om3-meta
export AWS_DEFAULT_REGION=$(aws configure get region --profile ${AWS_PROFILE})
docker run --rm -i -v $(PWD):/app -v $HOME/.aws:/root/.aws -w /app -e AWS_BUCKET_NAME="backup.om3.cloud" -e AWS_PROFILE="${AWS_PROFILE}" -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" -e PROM_PUSHGATEWAY_URL="http://${PROM_PUSHGATEWAY_HOST}" aoepeople/k8s_tools /bin/bash -c "/app/scripts/aws_s3_objects.sh"

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
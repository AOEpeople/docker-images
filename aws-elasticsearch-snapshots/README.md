# Creates and restores snapshots of the AWS Elasticsearch service to/from S3 

Required environment variables:

- ELASTICSEARCH_HOST
- S3_BUCKET
- REGION
- ROLE_ARN
- INDICES

See [Working with Amazon Elasticsearch Service Index Snapshots](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html#es-managedomains-snapshot-registerdirectory) for more details.
This container is based on the sample script provided there.

AWS related environment variables (if you don't use the instance profiles):
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_DEFAULT_REGION
# AWS Lambda Deployment

This docker image downloads a JAR file (which includes the whole lambda code) and uploads it to a S3 bucket. 
After that it will update the lambda code with the AWS CLI.

Example command:

```
docker run --rm -i \
  -e VERSION_NUMBER="1.2.3" \
  -e ARTIFACT_URL="https://domain.com/artifactory/.../###VERSION_NUMBER###/name-###VERSION_NUMBER###.jar" \
  -e AWS_BUCKET_NAME="bucket_name" \
  -e AWS_REGION="eu-west-1" \
  -e AWS_LAMBDA_JAR="name-###VERSION_NUMBER###.jar" \
  -e AWS_LAMBDA_FUNCTION="lambda_function_name" \
  -e DEBUG=1 \
  aoepeople/aws-lambda-deployment:0.1
```

If the artifactory URL is protected you could also additional environment variables

```
  -e USERNAME=xxx
  -e PASSWORD=yyy
```

## Persmissions

The operations inside this docker image requires permission for the lambda:UpdateFunctionCode action.
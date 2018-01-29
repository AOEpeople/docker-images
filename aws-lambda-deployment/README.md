# AWS Lambda Deployment

## Update lambda function code

This requires an existing Lambda artifact as a jar or zip package which is accessable via http(s).

**Steps:**
* Download artifact from external http(s) resource
* Upload artifact to a specific S3 bucket
* Update a specific lambda function

**Example command:**

```
docker run --rm -i \
  -e STAGE_NAME="latest" \
  -e VERSION_NUMBER="1.2.3" \
  -e ARTIFACT_URL="https://domain.com/artifactory/.../###VERSION_NUMBER###/name-###VERSION_NUMBER###.jar" \
  -e AWS_BUCKET_NAME="bucket_name_###STAGE_NAME###" \
  -e AWS_REGION="eu-west-1" \
  -e AWS_LAMBDA_ARTIFACT_NAME="name-###VERSION_NUMBER###.jar" \
  -e AWS_LAMBDA_FUNCTION="lambda_function_name_###STAGE_NAME###" \
  -e DEBUG=1 \
  aoepeople/aws-lambda-deployment:0.1 /bin/bash -c "/usr/local/bin/updateFunctionCode.sh"
```
As you can see you could use a marker ###VERSION_NUMBER### in ARTIFACT_URL and AWS_LAMBDA_ARTIFACT_NAME which will be replaced with the value of VERSION_NUMBER.
If the artifactory URL is protected by an HTTP Basic authentication you could add the additional environment variables

```
  -e USERNAME=xxx
  -e PASSWORD=yyy
```

### Required persmissions

The operations inside this docker image requires permission for the lambda:UpdateFunctionCode action and for the s3:PutObject action.


lambda:UpdateFunctionCode
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:UpdateFunctionCode"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:lambda:<region>:<account>:function:<functionName>"
    }
  ]
}
```

s3:PutObject
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::<bucket_name>/<key_name>",
      "Principal": "*"
    }
  ]
}
```
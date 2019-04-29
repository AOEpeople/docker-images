import boto3
import botocore.session
import requests
import os
import sys
import datetime
from requests_aws4auth import AWS4Auth

command = sys.argv[1]
esHost = os.getenv('ELASTICSEARCH_HOST', 'localhost:9200')
bucketName = os.environ['S3_BUCKET']
roleArn = os.getenv('ROLE_ARN', '')
indices = os.getenv('INDICES', '*')
region = os.getenv('REGION', 'us-west-1')

host = 'https://' + esHost + '/'
service = 'es'

try:
    session = botocore.session.get_session()
    credentials = session.get_credentials()
except:
    print("Unable to get AWS credentials")
    print(sys.exc_info()[0])
    exit(1)

try:
    awsAuth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)
except AttributeError as err:
    print("Unable to auth with AWS credentials")
    print(str(err), file=sys.stderr)
    exit(1)

path = '_snapshot/' + bucketName
headers = {"Content-Type": "application/json"}

url = host + path
snapshotRepositoryExistsRequest = requests.get(url, auth=awsAuth, headers=headers)

if snapshotRepositoryExistsRequest.status_code != 200:
    print("Adding Snapshot repository " + bucketName)
    path = '_snapshot/' + bucketName
    payload = {
        "type": "s3",
        "settings": {
            "bucket": bucketName,
            "region": region,
            "role_arn": roleArn,
        }
    }
    url = host + path
    r = requests.put(url, auth=awsAuth, json=payload, headers=headers)
    print(r.status_code)
    print(r.text)
else:
    print("Snapshot repository " + bucketName + " already exists")

if command == "create":
    snapshotName = 'snapshot-' + datetime.datetime.today().strftime('%Y-%m-%d-%H-%M')
    print("Creating snapshot " + snapshotName)
    path = '_snapshot/' + bucketName + '/' + snapshotName
    url = host + path
    r = requests.put(url, auth=awsAuth)
    print(r.status_code)
    print(r.text)
elif command == "restore":
    snapshotName = sys.argv[2]

    print("Restoring snapshot " + snapshotName)
    path = '_snapshot/' + bucketName + '/' + snapshotName + '/_restore'
    url = host + path

    payload = {
        "indices": indices,
        "rename_pattern": "(.+)",
        "rename_replacement": "$1_restored"
    }

    r = requests.post(url, auth=awsAuth, json=payload, headers=headers)

    print(r.status_code)
    print(r.text)
else:
    print("No valid command given")
    exit(1)

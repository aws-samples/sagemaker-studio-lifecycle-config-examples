# Installs a git helper function which retrieves the password or developer token from Secrets Manager 
# directly for cloning a repository from a private git repo or pushing back changes upstream. 
# Storing passwords and tokens in Secrets Manager eliminates the need to store any sensitive information on EFS.

# Steps:
# 1. Add your password or personal developer token to Secret Manager
# 2. Set the secret name and key in the script below
# 3. Clone your repository via HTTP with the user name in the url, e.g. "git clone http://username@github.com/...."

#!/bin/bash

set -eux

## Parameters 
# your git provider, e.g. github.com
GIT_PROVIDER="github.com"
GIT_USERNAME="garzoand"
AWS_REGION="us-west-2"
# Secret name stored in AWS Secrets Manager
AWS_SECRET_NAME="my-git-credentials"
# Secret key name inside the secret
AWS_SECRET_KEY="github.com"

## Script Body

PYTHON_EXEC=$(command -v python)
cat > ~/.aws-credention-helper.py <<EOL
#!$PYTHON_EXEC

import sys
import json
import boto3
import botocore

GIT_PROVIDER='$GIT_PROVIDER'
GIT_USERNAME='$GIT_USERNAME'
AWS_REGION='$AWS_REGION'
AWS_SECRET_NAME='$AWS_SECRET_NAME'
AWS_SECRET_KEY='$AWS_SECRET_KEY'

if len(sys.argv) < 2 or sys.argv[1] != 'get':
    exit(0)

credentials = {}
for line in sys.stdin:
    if line.strip() == "":
        break
    key, value = line.split('=')[0:2]
    credentials[key.strip()] = value.strip()

if credentials.get('host', '') == GIT_PROVIDER and \
    credentials.get('username', '') == GIT_USERNAME:
    client = boto3.client('secretsmanager', region_name=AWS_REGION)
    try:
        response = client.get_secret_value(SecretId=AWS_SECRET_NAME)
    except botocore.exceptions.ClientError as e:
        exit(1)
    if 'SecretString' in response:
        secret = response['SecretString']
        secret_dict = json.loads(secret)
        if AWS_SECRET_KEY in secret_dict:
            credentials['password'] = secret_dict[AWS_SECRET_KEY]

for key, value in credentials.items():
    print('{}={}'.format(key, value))

EOL

chmod +x ~/.aws-credention-helper.py
git config --global credential.helper ~/.aws-credention-helper.py


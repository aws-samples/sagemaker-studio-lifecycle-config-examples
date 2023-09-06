#!/bin/bash

set -eux

cat > ~/.download_ca_certs.py <<EOL
#!/opt/conda/bin/python3

import sys
import json
import boto3
import botocore
import os

# must be in same region as SM Studio
CA_CERT_BUCKET = '[s3_bucket_name]'

s3 = boto3.client('s3')
objects = s3.list_objects(Bucket=CA_CERT_BUCKET)

conda_cert_file = open('/opt/conda/ssl/cacert.pem', 'a+')

# Download all cert files from bucket and append to conda ca cert file
for object in objects['Contents']:
    if '/' not in object['Key']:
        s3.download_file(CA_CERT_BUCKET, object['Key'], object['Key'])
        current_file = open(object['Key'], 'r')
        contents = current_file.read()
        if "BEGIN CERTIFICATE" in contents and "END CERTIFICATE" in contents:
            conda_cert_file.write(contents + "\n")
        current_file.close()
        os.remove(object['Key'])

conda_cert_file.close()

EOL

chmod +x ~/.download_ca_certs.py
~/.download_ca_certs.py


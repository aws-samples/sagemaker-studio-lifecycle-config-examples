# This script configures proxy settings for your Jupyter Server and Kernel appliations
# This is useful for use cases where you would like to configure your notebook instance in your custom VPC
# without direct internet access to route all traffic via a proxy server in your VPC.

# Please ensure that you have already configure a proxy server in your VPC.

#!/bin/bash
 
set -eux

# PARAMETERS
PROXY_SERVER=http://proxy.local:3128
# Please note that we are excluding S3 because we do not want this traffic to be routed over the public internet, but rather through the S3 endpoint in the VPC.
EXCLUDED_HOSTS="s3.amazonaws.com,127.0.0.1,localhost"

mkdir -p ~/.ipython/profile_default/startup/
touch ~/.ipython/profile_default/startup/00-startup.py

echo "export http_proxy='$PROXY_SERVER'" | tee -a ~/.profile >/dev/null
echo "export https_proxy='$PROXY_SERVER'" | tee -a ~/.profile >/dev/null
echo "export no_proxy='$EXCLUDED_HOSTS'" | tee -a ~/.profile >/dev/null

echo "import sys,os,os.path" | tee -a ~/.ipython/profile_default/startup/00-startup.py >/dev/null
echo "os.environ['HTTP_PROXY']="\""$PROXY_SERVER"\""" | tee -a ~/.ipython/profile_default/startup/00-startup.py >/dev/null
echo "os.environ['HTTPS_PROXY']="\""$PROXY_SERVER"\""" | tee -a ~/.ipython/profile_default/startup/00-startup.py >/dev/null
echo "os.environ['NO_PROXY']="\""$EXCLUDED_HOSTS"\""" | tee -a ~/.ipython/profile_default/startup/00-startup.py >/dev/null

#!/bin/bash

set -eux

export LCC_SCRIPT_NAME='set-proxy'
export SCRIPT_FILE_NAME='scripts/set-proxy-settings/on-jupyter-server-start.sh'
export SCRIPT_TYPE="JupyterServer"
# export SCRIPT_TYPE="KernelGateway"

export LCC_CONTENT=`cat ${SCRIPT_FILE_NAME} | base64`

aws sagemaker --region us-east-2 create-studio-lifecycle-config \
  --studio-lifecycle-config-name $LCC_SCRIPT_NAME \
  --studio-lifecycle-config-content $LCC_CONTENT \
  --studio-lifecycle-config-app-type $SCRIPT_TYPE

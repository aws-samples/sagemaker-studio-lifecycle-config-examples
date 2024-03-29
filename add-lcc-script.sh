#!/bin/bash
# Registers a Lifecycle Configuration Script using the AWS CLI
# NOTE: This registration by itself will not attach or enable it for any domains/users yet

set -eux

export LCC_SCRIPT_NAME='set-proxy'
export SCRIPT_FILE_NAME='scripts/set-proxy-settings/on-jupyter-server-start.sh'
export SCRIPT_TYPE='JupyterServer'
# export SCRIPT_TYPE='KernelGateway'

LCC_CONTENT=`openssl base64 -A -in ${SCRIPT_FILE_NAME}`

aws sagemaker create-studio-lifecycle-config \
  --studio-lifecycle-config-name $LCC_SCRIPT_NAME \
  --studio-lifecycle-config-content $LCC_CONTENT \
  --studio-lifecycle-config-app-type $SCRIPT_TYPE

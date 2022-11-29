# This script configures page settings for your Jupyter Server in order to disable automatic startup of kernels on notebook access.

#!/bin/bash
 
set -eux

export AWS_SAGEMAKER_JUPYTERSERVER_IMAGE="${AWS_SAGEMAKER_JUPYTERSERVER_IMAGE:-'jupyter-server'}"
if [ "$AWS_SAGEMAKER_JUPYTERSERVER_IMAGE" != "jupyter-server-3" ] ; then
    echo "SageMaker version '$AWS_SAGEMAKER_JUPYTERSERVER_IMAGE' does not match 'jupyter-server-3'"
    echo "Skipping install (which depends on JupyterLab v3)"
    exit 0
fi

echo "Creating Jupyter page config."
mkdir ~/.jupyter/labconfig
touch ~/.jupyter/labconfig/page_config.json
echo {\"notebookStartsKernel\": false} > ~/.jupyter/labconfig/page_config.json

# Restart Jupyter to make sure configuration is picked up
echo "Restarting Jupyter server..."
restart-jupyter-server
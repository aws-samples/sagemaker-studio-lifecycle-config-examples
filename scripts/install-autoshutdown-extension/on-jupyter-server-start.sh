# Installs SageMaker Studio's Auto Shutdown Idle Kernel Sessions extension
#!/bin/bash

set -eux

sudo yum -y install wget
wget https://github.com/aws-samples/sagemaker-studio-auto-shutdown-extension/raw/main/sagemaker_studio_autoshutdown-0.1.1.tar.gz
pip install sagemaker_studio_autoshutdown-0.1.1.tar.gz
jlpm config set cache-folder /tmp/yarncache
jupyter lab build --debug --minimize=False

# restarts jupter server
nohup supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart jupyterlabserver

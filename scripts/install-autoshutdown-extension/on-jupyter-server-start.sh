# Installs SageMaker Studio's Auto Shutdown Idle Kernel Sessions extension
#!/bin/bash

set -eux

sudo yum -y install wget

# Saving the tarball to a file or folder with a '.' prefix will prevent it from cluttering up users' file tree views:
mkdir -p .auto-shutdown
wget -O .auto-shutdown/extension.tar.gz https://github.com/aws-samples/sagemaker-studio-auto-shutdown-extension/raw/main/sagemaker_studio_autoshutdown-0.1.5.tar.gz
pip install .auto-shutdown/extension.tar.gz
jlpm config set cache-folder /tmp/yarncache
jupyter lab build --debug --minimize=False

# restarts jupter server
nohup supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart jupyterlabserver

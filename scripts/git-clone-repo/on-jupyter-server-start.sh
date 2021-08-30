# Clones a git repository into the user's home folder
#!/bin/bash

set -eux

# Replace this with the URL of your git repository
export REPOSITORY_URL="https://github.com/aws-samples/sagemaker-studio-lifecycle-config-examples.git"

git -C /home/sagemaker-user clone $REPOSITORY_URL

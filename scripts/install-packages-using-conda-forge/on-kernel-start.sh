# This script installs a single conda-forge package on a SageMaker Studio Kernel Application using mamba for Data Science 3.0 and Data Science 2.0 Images
#!/bin/bash

set -eux

#sets the environment channels to conda-forge package repositories
conda config --add channels conda-forge
conda config --set channel_priority strict

# Install packages using Conda-Forge with mamba
nohup mamba install pypots -y
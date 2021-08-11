# This script installs a single pip package on a SageMaker Studio Kernel Application
#!/bin/bash

set -eux

# PARAMETERS
PACKAGE=pyarrow

pip install --upgrade $PACKAGE

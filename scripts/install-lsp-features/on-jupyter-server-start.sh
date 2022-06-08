#!/bin/bash
# Install and configure code completion tools *if* running high enough JupyterLab version

set -eu

# Minimum required JupyterLab version
# Per https://jupyterlab-lsp.readthedocs.io/en/latest/Installation.html
MIN_JLAB_VERSION='3.1.0'

# Function to compare two X.Y.Z semantic version strings
# Returns 0 if equal, 1 if A > B, 2 if A < B.
# From https://stackoverflow.com/a/4025065
compare_semvers () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

echo "Checking conda environments"
if conda info --envs | grep ^studio; then
    # Standard on JLv3 image at time of writing
    CONDA_ENV=studio
else
    # Standard on JLv1 image at time of writing
    CONDA_ENV=base
fi
echo "Activating conda env $CONDA_ENV"
source activate $CONDA_ENV

JLAB_VERSION=`jupyter lab --version`
echo "Found JupyterLab version $JLAB_VERSION"
set +e
compare_semvers $MIN_JLAB_VERSION $JLAB_VERSION
VERCOMP_RESULT=$?
set -e

if [ $VERCOMP_RESULT -eq 1 ]; then
    echo "JupyterLab version '$JLAB_VERSION' is less than '$MIN_JLAB_VERSION'"
    echo "Skipping autocomplete feature install"
    exit 0
fi

# Install the core JupyterLab LSP integration and whatever language servers you need:
# For list of language servers, see -
# https://jupyterlab-lsp.readthedocs.io/en/latest/Language%20Servers.html
echo "Installing jupyterlab-lsp and language servers"
pip install jupyterlab-lsp 'python-lsp-server[all]'
jlpm add --dev bash-language-server

# This configuration override is optional, to make LSP "extra-helpful" by default:
CMP_CONFIG_DIR=.jupyter/lab/user-settings/@krassowski/jupyterlab-lsp/
CMP_CONFIG_FILE=completion.jupyterlab-settings
CMP_CONFIG_PATH="$CMP_CONFIG_DIR/$CMP_CONFIG_FILE"
if test -f $CMP_CONFIG_PATH; then
    echo "jupyterlab-lsp config file already exists: Skipping default config setup"
else
    echo "Setting continuous hinting to enabled by default"
    mkdir -p $CMP_CONFIG_DIR
    echo '{ "continuousHinting": true }' > $CMP_CONFIG_PATH
fi

# Similarly could set other configurations for LSP services:
echo "Configuring pycodestyle linter max line width"
mkdir -p ~/.config
cat > ~/.config/pycodestyle <<EOF
[pycodestyle]
max-line-length = 100
EOF

# Once components are installed and configured, restart Jupyter to make sure everything propagates:
echo "Restarting Jupyter server..."
nohup supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart jupyterlabserver \
    > /dev/null 2>&1

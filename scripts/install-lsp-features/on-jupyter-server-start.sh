#!/bin/bash
# Install and configure assistive IDE tools *if* running high enough JupyterLab version (v3)
#
# This script sets up code completion, continuous hinting, hover tips, code formatting, markdown
# spell-checking, and an S3 bucket explorer UI. See below comments for details.

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
    echo "Skipping assistive features install"
    exit 0
fi

# Install:
# - The core JupyterLab LSP integration and whatever language servers you need (omitting autopep8
#   and yapf code formatters for Python, which don't yet have integrations per
#   https://github.com/jupyter-lsp/jupyterlab-lsp/issues/632)
# - Additional LSP plugins for formatting (black, isort) and refactoring (rope)
# - Spellchecker for markdown cells
# - Code formatting extension to bridge the LSP gap, and supported formatters
# - Amazon S3 browser sidebar extension
echo "Installing jupyterlab-lsp and language tools"
pip install jupyterlab-lsp \
    'python-lsp-server[flake8,mccabe,pycodestyle,pydocstyle,pyflakes,pylint,rope]' \
    jupyterlab-spellchecker \
    jupyterlab-code-formatter black isort \
    jupyterlab-s3-browser
# Some LSP language servers install via JS, not Python. For full list of language servers see:
# https://jupyterlab-lsp.readthedocs.io/en/latest/Language%20Servers.html
jlpm add --dev bash-language-server dockerfile-language-server-nodejs

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

# Similarly could set other configurations. Line width is unfortunately configured separately for
# several of these plugins:
FMT_CONFIG_DIR=~/.jupyter/lab/user-settings/@ryantam626/jupyterlab_code_formatter
FMT_CONFIG_FILE=settings.jupyterlab-settings
FMT_CONFIG_PATH="$FMT_CONFIG_DIR/$FMT_CONFIG_FILE"
if test -f $FMT_CONFIG_PATH; then
    echo "jupyterlab-code-formatter config file already exists: Skipping default config setup"
else
    echo "Configuring jupyterlab-code-formatter format on save and line width"
    mkdir -p $FMT_CONFIG_DIR
    cat > $FMT_CONFIG_PATH <<EOF
{"black": {"line_length": 100}, "isort": {"line_length": 100}, "formatOnSave": true}
EOF
fi
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

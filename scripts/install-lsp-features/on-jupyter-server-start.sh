#!/bin/bash
# Install and configure assistive IDE tools *if* running high enough JupyterLab version (v3)
#
# This script sets up code completion, continuous hinting, hover tips, code formatting, and
# markdown spell-checking. Includes some config setting on these tools - see below for details.

set -eu

export AWS_SAGEMAKER_JUPYTERSERVER_IMAGE="${AWS_SAGEMAKER_JUPYTERSERVER_IMAGE:-'jupyter-server'}"
if [ "$AWS_SAGEMAKER_JUPYTERSERVER_IMAGE" != "jupyter-server-3" ] ; then
    echo "SageMaker version '$AWS_SAGEMAKER_JUPYTERSERVER_IMAGE' does not match 'jupyter-server-3'"
    echo "Skipping assistive features install (which depends on JupyterLab v3)"
    exit 0
fi

# Activate the conda environment where Jupyter is installed:
eval "$(conda shell.bash hook)"
conda activate studio

# Install:
# - The core JupyterLab LSP integration and whatever language servers you need (omitting autopep8
#   and yapf code formatters for Python, which don't yet have integrations per
#   https://github.com/jupyter-lsp/jupyterlab-lsp/issues/632)
# - Additional LSP plugins for formatting (black, isort) and refactoring (rope)
# - Spellchecker for markdown cells
# - Code formatting extension to bridge the LSP gap, and supported formatters
echo "Installing jupyterlab-lsp and language tools"
pip install jupyterlab-lsp \
    'python-lsp-server[flake8,mccabe,pycodestyle,pydocstyle,pyflakes,pylint,rope]' \
    jupyterlab-spellchecker \
    jupyterlab-code-formatter black isort
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

# Similarly can set other configurations. Note:
# - Line width is unfortunately configured separately for several of these plugins.
# - If you enable automatic "formatOnSave" as shown here, you'll see an error dialog when saving a
#   notebook with incomplete/invalid Python syntax - but the file should still save.
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

conda deactivate

# Once components are installed and configured, restart Jupyter to make sure everything propagates:
echo "Restarting Jupyter server..."
nohup supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart jupyterlabserver \
    > /dev/null 2>&1

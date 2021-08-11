# SageMaker Studio Lifecycle Configuration Samples

### Overview

A collection of sample scripts customizing SageMaker Studio Applications using Lifecycle Configuration

Lifecycle Configurations provide a mechanism to customize the Jupyter Server and Kernel Application instances via shell scripts that are executed during the lifecycle of the application.

#### Sample Scripts

* [install-autoshutdown-extension](scripts/install-autoshutdown-extensions) -
* [install-pip-package-on-kernel](scripts/install-pip-package-on-kernel) - 
* [set-git-config](scripts/set-git-config) - This script sets the username and email address in Git config.
* [set-git-credentials](scripts/set-git-credentials) - Adds the user's git credentials to Secret Manager and configures git to fetch the credentials from there when needed
* [set-proxy-settings](scripts/set-proxy-settings) - Configures HTTP and HTTPS proxy settings on jupter server and on the Studio kernels.

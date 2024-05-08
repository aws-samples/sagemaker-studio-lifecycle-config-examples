# SageMaker Studio Classic Lifecycle Configuration Samples

### Overview

A collection of sample scripts customizing SageMaker Studio Classic Applications using Lifecycle Configurations. **To customize the new Studio experience that runs on JupyterLab applications (including an LCC script to automatically shut down idle JupyterLab apps), refer to the repository here - https://github.com/aws-samples/sagemaker-studio-apps-lifecycle-config-examples/tree/main.**

Lifecycle Configurations for [Studio Classic](https://docs.aws.amazon.com/sagemaker/latest/dg/studio.html) provide a mechanism to customize the Jupyter Server and Kernel Application instances via shell scripts that are executed during the lifecycle of the application. For information on customizing Studio Classic using Lifecycle configurations, refer to the [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-lcc.html). In addition to the directions to set LCC script using the AWS CLI as showcased in this repository, you can also create and assign the LCCs to domains or users through the AWS Console. For console instructions, see [here](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-lcc-create-console.html). 

> ⚠️ **Warning:** If you're using a Windows computer, be aware LCC scripts must use Unix-style `LF` [line endings](https://stackoverflow.com/questions/1552749/difference-between-cr-lf-lf-and-cr-line-break-types) rather than Windows-style `CRLF`. You might find issues if uploading scripts through the AWS Console today, so we'd suggest using the CLI/APIs instead

#### Sample Scripts

* [git-clone-repo](scripts/git-clone-repo) - Checks out a Git repository under the user's home folder automatedly when the Jupter server starts
* [install-autoshutdown-server-extension](scripts/install-autoshutdown-server-extension) (Recommended) - Installs only the server part of idle-kernel shutdown extension. No external dependencies to install, recommended to use in VPCOnly mode with restricted Internet connectivity. Idle timelimit has to be set using Life Cycle Configuration script.
* [install-autoshutdown-extension](scripts/install-autoshutdown-extension) - Installs the auto idle-kernel shutdown extension on the Jupyter Server. This install allows users to set idle timeout limit using the UI. ***Note***: *The UI plugin is only compatible with JupyterLab v1.0. See [JupyterLab versioning](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jl.html) for JupyterLab versions in SageMaker Studio.*
* [install-lsp-features](scripts/install-lsp-features) - Installs coding assistance tools to enable features like auto-completion, linting, and hover suggestions in Studio JupyterLab v3+.
* [[install-packages-using-conda-forge](scripts/install-packages-using-conda-forge)] - Installs packages using conda-forge channels and uses MAMBA to install them.
* [disable-automatic-kernel-start](disable-automatic-kernel-start) - Disables automatic starting of kernel when opening notebooks. Only works with Studio JupyterLab v3.3+.
* [install-pip-package-on-kernel](scripts/install-pip-package-on-kernel) - Installs a python package with pip on a Studio Kernel
* [set-git-config](scripts/set-git-config) - This script sets the username and email address in Git config.
* [set-git-credentials](scripts/set-git-credentials) - Adds the user's git credentials to Secret Manager and configures git to fetch the credentials from there when needed
* [set-proxy-settings](scripts/set-proxy-settings) - Configures HTTP and HTTPS proxy settings on jupter server and on the Studio kernels.

#### Troubleshooting

When a Studio app is started with a LCC enabled, an Amazon CloudWatch Log stream is created within the [/aws/sagemaker/studio log group](https://console.aws.amazon.com/cloudwatch/home?#logsV2:log-groups/log-group/$252Faws$252Fsagemaker$252Fstudio) (you must be signed in to your AWS account for this link to work), with a name like `$DOMAIN_ID/$USER_PROFILE_NAME/$APP_TYPE/$APP_NAME/LifecycleConfigOnStart` (where e.g. `$APP_TYPE` could be  `JupyterServer` or `KernelGateway` for Studio Classic apps). You can use these log streams to debug any problems while customizing your LCCs.

#### Developing LCC Scripts for SageMaker Studio

For best practicies, please check the [DEVELOPMENT.md](DEVELOPMENT.md).

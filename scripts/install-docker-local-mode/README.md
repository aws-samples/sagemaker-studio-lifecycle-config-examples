# Install Docker and enable SageMaker Local Mode

While running SageMaker jobs using on-demand compute is great for optimizing infrastructure consumption and tracking experiments, waiting for infrastructure start-up each time is not the fastest workflow for **debugging** custom training scripts and containers. There are multiple tools available to accelerate this process, including:

1. [SageMaker Managed Warm Pools](https://docs.aws.amazon.com/sagemaker/latest/dg/train-warm-pools.html), which allows you to keep your instance(s) "warm" for a specified time-out period after a training job completes - and start new jobs on them in seconds rather than minutes.
2. Using AWS Systems Manager to [remotely access](https://docs.aws.amazon.com/sagemaker/latest/dg/train-remote-debugging.html) running training containers (or even other SageMaker resources, using the [SageMaker SSH Helper toolkit](https://github.com/aws-samples/sagemaker-ssh-helper)) to use remote interactive debugging tools.
3. **[SageMaker Local Mode](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html)**, which uses the [Docker CLI](https://docs.docker.com/engine/reference/run/) and [Docker Compose CLI](https://docs.docker.com/compose/reference/) to **emulate** (a subset of) SageMaker runtime features on your local notebook/machine using the same target container image.

While [SageMaker Local Mode is now available in SageMaker Studio environments](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html), it requires some configuration to enable - which this sample demonstrates.


## Pre-requisites

### Enable Studio Docker Access

As [noted in the developer guide](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-local.html#studio-updated-local-enable), you'll first need to enable Docker access in your Studio Domain. See the developer guide for more configuration options:

```sh
aws --region $YOUR_REGION \
    sagemaker update-domain --domain-id $YOUR_DOMAIN_ID \
    --domain-settings-for-update '{"DockerSettings": {"EnableDockerAccess": "ENABLED"}}'
```


### Check your `sagemaker` SDK version

Support for SageMaker Local Mode in Studio environments was [added in v2.203.0](https://github.com/aws/sagemaker-python-sdk/blob/master/CHANGELOG.md#v22030-2023-12-28), which at the time of writing is not yet reflected in the default SageMaker JupyterLab ([SageMaker Distribution v1.3](https://github.com/aws/sagemaker-distribution)) image.

```python
# To check your installed version:
import sagemaker
print(sagemaker.__version__)

# To upgrade from within a notebook:
%pip install --upgrade sagemaker
```

> ⚠️ If you're working in a notebook and already ran an `import` from `sagemaker`, you'll need to **restart the kernel** for this change to take effect.
>
> The provided LCC attempts to automate this upgrade on app start, but may miss some environments if you have custom kernels set up.


## Set up the Lifecycle Configuration Script

Use the commands in [on-start.sh](./on-start.sh) to create a LCC of type `JupyterLab` **OR** `CodeEditor`, and attach it to your Studio Domain and/or User Profile (See the general guidance in [this repository's root README](../../README.md) for more details on these steps, and debugging if things go wrong).

The same script code should work for either JupyterLab and Code Editor spaces, but if you want to use both you'll need to create a separate SageMaker LCC for each type.


## Verify your setup

After (re)-starting your JupyterLab Space with the LCC attached, you should be able to run `docker --version` and/or `docker run --net sagemaker hello-world` from a terminal.

From a Python notebook or terminal (re-check your `sagemaker` SDK version!), you should now be able to start [exploring Local Mode](https://sagemaker.readthedocs.io/en/stable/overview.html#local-mode). We tested with the `pytorch_script_mode_local_model_inference` and `amazon-sagemaker-local-mode/pytorch_script_mode_local_training_and_serving` samples from https://github.com/aws-samples/amazon-sagemaker-local-mode - where you can also find other examples.

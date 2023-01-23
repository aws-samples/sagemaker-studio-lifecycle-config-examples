## Auto shutdown server extension

**Please read carefully**

1. The process for installing JupyterLab and Jupyter Server extensions differs depending on the JupyterLab version of your Studio instance. In JupyterLab 1, you can install extensions without activating any conda environment. In JupyterLab 3, you must activate the `studio` conda environment before installing extensions. The script for adding the auto-shutdown extension has been updated to work with both versions of JupyterLab. 

2. If you are merging multiple LCC scripts into one default LCC script for your domain, ensure that the auto shutdown extension is the last to be installed. Specifically, the [line to set the time interval](https://github.com/durgasury/sagemaker-studio-lifecycle-config-examples/blob/update-plugin-readme/scripts/install-autoshutdown-server-extension/on-jupyter-server-start.sh#L75) should be the last to be executed. This line starts the polling for idle kernels, and if there are `restart-jupyter-server` commands executed after this line, the plugin will not be polling for idle apps and shutting them down.

For more information, see [Installing JupyterLab and Jupyter Server extensions](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jl.html#studio-jl-install).

You can read more about the launch in the [blog post here](https://aws.amazon.com/blogs/machine-learning/amazon-sagemaker-studio-and-sagemaker-notebook-instance-now-come-with-jupyterlab-3-notebooks-to-boost-developer-productivity/). 

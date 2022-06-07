## Auto shutdown server extension

The process for installing JupyterLab and Jupyter Server extensions differs depending on the JupyterLab version of your Studio instance. In JupyterLab 1, you can install extensions without activating any conda environment. 

In JupyterLab 3, you must activate the `studio` conda environment before installing extensions. The script for adding the auto-shutdown extension has been updated to work with both versions of JupyterLab. 

For more information, see [Installing JupyterLab and Jupyter Server extensions](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jl.html#studio-jl-install).

You can read more about the launch in the [blog post here](https://aws.amazon.com/blogs/machine-learning/amazon-sagemaker-studio-and-sagemaker-notebook-instance-now-come-with-jupyterlab-3-notebooks-to-boost-developer-productivity/). 
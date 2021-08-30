## Best Practicies for Developing Life-Cycle Configuration Scripts for SageMaker Studio

1. You can test Jupyter Server side scripts in the **System Terminal**. For Kernel side scripts please start an **Image Terminal** for the target kernel and run your script from there. If the scripts are running without issues in terminals, you can safely assume it will run as an LCC script as well

2. Always add the "set -eux" command to the beginning of your script. This command will print out the commands executed by your script line by line and will be visible in the logs as well. This helps you to troubleshoot your scripts faster.

3. Be careful using the "sudo" command in KernelGateways scripts. Not all kernels runs as root by default. If the kernel run as root, don't use the sudo command. Use sudo command only when the Kernel runs as a non-root default user.


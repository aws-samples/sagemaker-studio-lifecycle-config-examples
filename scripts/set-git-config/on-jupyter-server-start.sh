# This scripts sets username and email address in Git config
#!/bin/bash

# stop the script execution on error
set -e

# PARAMETERS
YOUR_USER_NAME="your_user_name"
YOUR_EMAIL_ADDRESS="your_email_address"

git config --global user.name "$YOUR_USER_NAME"
git config --global user.email "$YOUR_EMAIL_ADDRESS"

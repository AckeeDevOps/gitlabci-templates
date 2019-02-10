#!/bin/sh

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

echo "Running validation sequence for CI test with secrets ..."

# Check if variables exist
[ -z "$VAULTIER_BRANCH" ] && { echo "VAULTIER_BRANCH is required"; exit 1; }
[ -z "$VAULTIER_SECRET_SPECS_PATH" ] && { echo "VAULTIER_SECRET_SPECS_PATH is required"; exit 1; }
[ -z "$VAULTIER_RUN_CAUSE" ] && { echo "VAULTIER_RUN_CAUSE is required"; exit 1; }
[ -z "$VAULTIER_OUTPUT_FORMAT" ] && { echo "VAULTIER_OUTPUT_FORMAT is required"; exit 1; }
[ -z "$VAULTIER_SECRET_OUTPUT_PATH" ] && { echo "VAULTIER_SECRET_OUTPUT_PATH is required"; exit 1; }
[ -z "$SSH_KEY" ] && { echo "SSH_KEY is required"; exit 1; }

# Perform more sophisticated tests
echo ${SSH_KEY} | base64 -d | openssl rsa -noout > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "SSH_KEY is broken. Make sure it's base64 encoded RSA private key"
  exit 1
fi

echo "${green}Everything is silky smooth, well done!${reset}"

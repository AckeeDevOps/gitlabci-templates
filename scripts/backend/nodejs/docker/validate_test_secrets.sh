#!/bin/sh

echo "Running validation sequence for CI test with secrets ..."

# Check if variables exist
[ -z "$VAULTIER_BRANCH" ] && { echo "VAULTIER_BRANCH is required"; exit 1; }
[ -z "$VAULTIER_SECRET_SPECS_PATH" ] && { echo "VAULTIER_SECRET_SPECS_PATH is required"; exit 1; }
[ -z "$VAULTIER_RUN_CAUSE" ] && { echo "VAULTIER_RUN_CAUSE is required"; exit 1; }
[ -z "$VAULTIER_OUTPUT_FORMAT" ] && { echo "VAULTIER_OUTPUT_FORMAT is required"; exit 1; }
[ -z "$VAULTIER_SECRET_OUTPUT_PATH" ] && { echo "VAULTIER_SECRET_OUTPUT_PATH is required"; exit 1; }
[ -z "$VAULTIER_VAULT_ADDR" ] && { echo "VAULTIER_VAULT_ADDR is required"; exit 1; }
[ -z "$VAULTIER_VAULT_TOKEN" ] && { echo "VAULTIER_VAULT_TOKEN is required"; exit 1; }
[ -z "$SSH_KEY" ] && { echo "SSH_KEY is required"; exit 1; }

# Perform more sophisticated tests
echo ${SSH_KEY} | base64 -d | openssl rsa -noout > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "SSH_KEY is broken. Make sure it's base64 encoded RSA private key"
  exit 1
fi

token_size=$(echo ${VAULTIER_VAULT_TOKEN} | wc -c)
if [ $token_size -ne 27 ]; then
  echo "VAULTIER_VAULT_TOKEN should have exactly 27 characters"
  exit 1
fi

echo "Everything is silky smooth, well done!"
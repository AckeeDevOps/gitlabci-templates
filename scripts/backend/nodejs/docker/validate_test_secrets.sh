#!/bin/sh

echo "Running validation sequence for CI test with secrets ..."

if [ "$DEBUG_MODE" = true ]; then
  token_short=$(echo "$VAULTIER_VAULT_TOKEN" | head -c 10)
  ssh_key_short=$(echo "$SSH_KEY" | head -c 10)

  echo "-----------------------------------"
  echo "content of variables for debugging:"
  echo "VAULTIER_BRANCH: ${VAULTIER_BRANCH}"
  echo "VAULTIER_SECRET_SPECS_PATH: ${VAULTIER_SECRET_SPECS_PATH}"
  echo "VAULTIER_RUN_CAUSE: ${VAULTIER_RUN_CAUSE}"
  echo "VAULTIER_OUTPUT_FORMAT: ${VAULTIER_OUTPUT_FORMAT}"
  echo "VAULTIER_SECRET_OUTPUT_PATH: ${VAULTIER_SECRET_OUTPUT_PATH}"
  echo "VAULTIER_VAULT_ADDR ${VAULTIER_VAULT_ADDR}"
  echo "VAULTIER_VAULT_TOKEN: ${token_short}..."
  echo "SSH_KEY: ${ssh_key_short}..."
  echo "-----------------------------------"
fi

# Check if variables exist
[ -z "$VAULTIER_BRANCH" ] && { echo "VAULTIER_BRANCH is required"; exit 1; }
[ -z "$VAULTIER_SECRET_SPECS_PATH" ] && { echo "VAULTIER_SECRET_SPECS_PATH is required"; exit 1; }
[ -z "$VAULTIER_RUN_CAUSE" ] && { echo "VAULTIER_RUN_CAUSE is required"; exit 1; }
[ -z "$VAULTIER_OUTPUT_FORMAT" ] && { echo "VAULTIER_OUTPUT_FORMAT is required"; exit 1; }
[ -z "$VAULTIER_SECRET_OUTPUT_PATH" ] && { echo "VAULTIER_SECRET_OUTPUT_PATH is required"; exit 1; }
[ -z "$VAULTIER_VAULT_ADDR" ] && { echo "VAULTIER_VAULT_ADDR is required"; exit 1; }
[ -z "$VAULTIER_VAULT_TOKEN" ] && { echo "VAULTIER_VAULT_TOKEN is required"; exit 1; }
[ -z "$SSH_KEY" ] && { echo "SSH_KEY is required"; exit 1; }
[ -z "$NODE_IMAGE" ] && { echo "NODE_IMAGE is required"; exit 1; }

# Perform more sophisticated tests
# Check valid RSA key, in alpine images make sure you have 'openssl' installed
if ! echo "${SSH_KEY}" | base64 -d | openssl rsa -noout > /dev/null 2>&1
then
  echo "SSH_KEY is broken. Make sure it's base64 encoded RSA private key"
  exit 1
fi

# Check valid Vault token
if [ "${#VAULTIER_VAULT_TOKEN}" -ne 27 ]; then
  echo "VAULTIER_VAULT_TOKEN should have exactly 27 characters"
  exit 1
fi

# Notify about success
echo "Everything is silky smooth, well done!"

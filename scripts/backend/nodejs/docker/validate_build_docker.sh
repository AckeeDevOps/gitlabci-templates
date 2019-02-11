#!/bin/sh

echo "Running validation sequence for Build of Docker image ..."

[ -z "$GCLOUD_PROJECT_ID" ] && { echo "GCLOUD_PROJECT_ID is required"; exit 1; }
[ -z "$PROJECT_NAME" ] && { echo "PROJECT_NAME is required"; exit 1; }
[ -z "$APP_NAME" ] && { echo "APP_NAME is required"; exit 1; }
[ -z "$IMAGE_TAG" ] && { echo "IMAGE_TAG is required"; exit 1; }
[ -z "$IMAGE_NAME" ] && { echo "IMAGE_NAME is required"; exit 1; }
[ -z "$SSH_KEY" ] && { echo "SSH_KEY is required"; exit 1; }
[ -z "$NODE_IMAGE" ] && { echo "NODE_IMAGE is required"; exit 1; }

# Perform more sophisticated tests
# Check valid RSA key
echo ${SSH_KEY} | base64 -d | openssl rsa -noout > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "SSH_KEY is broken. Make sure it's base64 encoded RSA private key"
  exit 1
fi

# Notify about success
echo "Everything is silky smooth, well done!"
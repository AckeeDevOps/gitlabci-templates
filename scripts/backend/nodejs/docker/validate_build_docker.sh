#!/bin/sh

echo "Running validation sequence for Build of Docker image ..."

if [ "$DEBUG_MODE" = true ]; then
  ssh_key_short=$(echo "$SSH_KEY" | head -c 10)
  gcloud_sa_key_short=$(echo "$GCLOUD_SA_KEY" | head -c 10)

  echo "-----------------------------------"
  echo "content of variables for debugging:"
  echo "GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID}"
  echo "PROJECT_NAME: ${PROJECT_NAME}"
  echo "APP_NAME: ${APP_NAME}"
  echo "IMAGE_NAME: ${IMAGE_NAME}"
  echo "IMAGE_TAG: ${IMAGE_TAG}"
  echo "NODE_IMAGE ${NODE_IMAGE}"
  echo "SSH_KEY: ${ssh_key_short}..."
  echo "GCLOUD_SA_KEY: ${gcloud_sa_key_short}..."
  echo "-----------------------------------"
fi

[ -z "$GCLOUD_PROJECT_ID" ] && { echo "GCLOUD_PROJECT_ID is required"; exit 1; }
[ -z "$PROJECT_NAME" ] && { echo "PROJECT_NAME is required"; exit 1; }
[ -z "$APP_NAME" ] && { echo "APP_NAME is required"; exit 1; }
[ -z "$IMAGE_TAG" ] && { echo "IMAGE_TAG is required"; exit 1; }
[ -z "$IMAGE_NAME" ] && { echo "IMAGE_NAME is required"; exit 1; }
[ -z "$SSH_KEY" ] && { echo "SSH_KEY is required"; exit 1; }
[ -z "$GCLOUD_SA_KEY" ] && { echo "GCLOUD_SA_KEY is required"; exit 1; }
[ -z "$NODE_IMAGE" ] && { echo "NODE_IMAGE is required"; exit 1; }

# Perform more sophisticated tests
# Check valid RSA key, in alpine images make sure you have 'openssl' installed
if echo "${SSH_KEY}" | base64 -d | openssl rsa -noout > /dev/null 2>&1
then
  echo "SSH_KEY is broken. Make sure it's base64 encoded RSA private key"
  exit 1
fi

# Notify about success
echo "Everything is silky smooth, well done!"

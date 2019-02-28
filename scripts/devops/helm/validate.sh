#!/bin/sh

# HELM_REPOSITORY_URL
# HELM_REPOSITORY_NAME
# HELM_REPOSITORY_USERNAME
# HELM_REPOSITORY_PASSWORD
# HELM_BINARIES_URL

echo "Running validation sequence for Helm pipeline ..."

if [ "$DEBUG_MODE" = true ]; then
  password_masked=$(echo "${HELM_REPOSITORY_PASSWORD}" | sed 's/./*/g')

  echo "-----------------------------------"
  echo "HELM_REPOSITORY_URL: ${HELM_REPOSITORY_URL}"
  echo "HELM_REPOSITORY_NAME: ${HELM_REPOSITORY_NAME}"
  echo "HELM_REPOSITORY_USERNAME: ${HELM_REPOSITORY_USERNAME}"
  echo "HELM_REPOSITORY_PASSWORD: ${password_masked}"
  echo "HELM_BINARIES_URL: ${HELM_BINARIES_URL}"
  echo "-----------------------------------"
fi

[ -z "$HELM_REPOSITORY_URL" ] && { echo "HELM_REPOSITORY_URL is required"; exit 1; }
[ -z "$HELM_REPOSITORY_NAME" ] && { echo "HELM_REPOSITORY_NAME is required"; exit 1; }
[ -z "$HELM_REPOSITORY_USERNAME" ] && { echo "HELM_REPOSITORY_USERNAME is required"; exit 1; }
[ -z "$HELM_REPOSITORY_PASSWORD" ] && { echo "HELM_REPOSITORY_PASSWORD is required"; exit 1; }
[ -z "$HELM_BINARIES_URL" ] && { echo "HELM_BINARIES_URL is required"; exit 1; }

echo "Everything is silky smooth, well done!"

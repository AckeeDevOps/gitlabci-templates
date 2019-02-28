#!/bin/sh

echo "Now installing helm ..."

# Add required packages
apk add ca-certificates git > /dev/null 2>&1

# Download Helm binaries
wget "${HELM_BINARIES_URL}" -O helm.tar.gz > /dev/null 2>&1

# Extract binaries
tar -xvf helm.tar.gz > /dev/null 2>&1

# Move helm to bin directory
mv linux-amd64/helm /usr/local/bin

# Clean temporary files
rm -rf linux-amd64 helm.tar.gz

# Initialize helm without Tiller
helm init --client-only > /dev/null 2>&1

# Install Helm plugins
helm plugin install https://github.com/chartmuseum/helm-push > /dev/null 2>&1
helm plugin install https://github.com/lrills/helm-unittest > /dev/null 2>&1

# Add remote repository
helm repo add \
  --username "${HELM_REPOSITORY_USERNAME}" \
  --password "${HELM_REPOSITORY_PASSWORD}" \
  "${HELM_REPOSITORY_NAME}" \
  "${HELM_REPOSITORY_URL}" > /dev/null 2>&1


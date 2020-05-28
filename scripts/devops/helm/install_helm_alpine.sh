#!/bin/sh

echo "Now installing helm ..."

# Add required packages
apk add ca-certificates git

# Download Helm binaries
wget "${HELM_BINARIES_URL}" -O helm.tar.gz

# Extract binaries
tar -xvf helm.tar.gz

# Move helm to bin directory
mv linux-amd64/helm /usr/local/bin

# Clean temporary files
rm -rf linux-amd64 helm.tar.gz

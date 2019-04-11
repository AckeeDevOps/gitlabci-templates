#!/bin/sh

# HELM_BINARIES_URL

echo "Running validation sequence for Helm pipeline ..."

if [ "${DEBUG_MODE}" = true ]; then
  echo "-----------------------------------"
  echo "HELM_BINARIES_URL: ${HELM_BINARIES_URL}"
  echo "-----------------------------------"
fi

[ -z "${HELM_BINARIES_URL}" ] && { echo "HELM_BINARIES_URL is required"; exit 1; }

echo "Everything is silky smooth, well done!"

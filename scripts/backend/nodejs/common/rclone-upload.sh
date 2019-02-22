#!/bin/sh

# Required variables:
#   GCLOUD_SA_KEY: base64 encoded string with service account key (cat /pat/to/key | base64 -w0)
#   GCLOUD_PROJECT_ID: gcloud project ID in plain text e.g. 'my-project-12345'
#   AGLIO_DOCS_DIRECTORY: directory with output HTML docs, relative or absolute path
#     example: ./docs-output/.
#   GCS_BUKET: name or GCS bucket e.g. my-bucket-name
#   GCS_PREFIX: a path where your files will be uploaded, should start with / e.g. /project-name/master/

# Check required variables
[ -z "$GCLOUD_SA_KEY" ] && { echo "GCLOUD_SA_KEY is required"; exit 1; }
[ -z "$GCLOUD_PROJECT_ID" ] && { echo "GCLOUD_PROJECT_ID is required"; exit 1; }
[ -z "$AGLIO_DOCS_DIRECTORY" ] && { echo "AGLIO_DOCS_DIRECTORY is required"; exit 1; }
[ -z "$GCS_BUKET" ] && { echo "GCS_BUKET is required"; exit 1; }
[ -z "$GCS_PREFIX" ] && { echo "GCS_PREFIX is required"; exit 1; }

# create SA key file
echo "$GCLOUD_SA_KEY" | base64 -d > /tmp/key.json

# set rclone variables
export RCLONE_GCS_PROJECT_NUMBER=${GCLOUD_PROJECT_ID}
export RCLONE_GCS_SERVICE_ACCOUNT_FILE=/tmp/key.json

# create rclone configuration
rclone config create remote gcs > /dev/null 2>&1

# upload files to GCS
rclone sync "${AGLIO_DOCS_DIRECTORY}" remote:"${GCS_BUKET}${GCS_PREFIX}" > /dev/null 2>&1

# list files for logging purposes
echo "Uploaded files:"
rclone ls remote:"${GCS_BUKET}${GCS_PREFIX}"
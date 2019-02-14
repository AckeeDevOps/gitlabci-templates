#!/bin/sh

echo "Running validation sequence for Documentation ..."

# load shared helpers
wget -q https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/scripts/general/validate_variables.sh -O /usr/local/bin/validate_variables.sh
source /usr/local/bin/validate_variables.sh

if [ "$DEBUG_MODE" = true ]; then
  gcloud_sa_key_short=$(echo $GCLOUD_SA_KEY | head -c 10)

  echo "-----------------------------------"
  echo "content of variables for debugging:"
  echo "GCLOUD_SA_KEY: ${gcloud_sa_key_short}..."
  echo "AGLIO_DOCS_DIRECTORY: ${AGLIO_DOCS_DIRECTORY}"
  echo "GCS_BUKET: ${GCS_BUKET}"
  echo "GCS_PREFIX: ${GCS_PREFIX}"
  echo "-----------------------------------"
fi

#[ -z "$GCLOUD_SA_KEY" ] && { echo "GCLOUD_SA_KEY is required"; exit 1; }
#[ -z "$AGLIO_DOCS_DIRECTORY" ] && { echo "AGLIO_DOCS_DIRECTORY is required"; exit 1; }
#[ -z "$GCS_BUKET" ] && { echo "GCS_BUKET is required"; exit 1; }
#[ -z "$GCS_PREFIX" ] && { echo "GCS_PREFIX is required"; exit 1; }

not_empty GCLOUD_SA_KEY || exit 1
not_empty AGLIO_DOCS_DIRECTORY || exit 1
not_empty GCS_BUKET || exit 1
not_empty GCS_PREFIX || exit 1

# Notify about success
echo "Everything is silky smooth, well done!"

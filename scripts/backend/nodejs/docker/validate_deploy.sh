#!/bin/sh

echo "Running validation sequence for Deploy Helm chart without secrets ..."

[ -z "$HELM_DRY_RUN" ] && { export HELM_DRY_RUN=false; }

if [ "$DEBUG_MODE" = true ]; then
  gcloud_sa_key_short=$(echo "$GCLOUD_SA_KEY" | head -c 10)
  token_short=$(echo "$VAULTIER_VAULT_TOKEN" | head -c 10)

  echo "-----------------------------------"
  echo "content of variables for debugging:"
  echo "GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID}"
  echo "GCLOUD_GKE_CLUSTER_NAME: ${GCLOUD_GKE_CLUSTER_NAME}"
  echo "GCLOUD_GKE_ZONE: ${GCLOUD_GKE_ZONE}"  
  echo "GCLOUD_SA_KEY: ${gcloud_sa_key_short}..."
  echo "GCLOUD_GKE_NAMESPACE: ${GCLOUD_GKE_NAMESPACE}"
  
  echo "-----------------------------------"
  echo "APP_NAME: ${APP_NAME}"
  echo "PROJECT_NAME: ${PROJECT_NAME}"
  echo "CI_ENVIRONMENT_NAME: ${CI_ENVIRONMENT_NAME}"
  echo "IMAGE_TAG: ${IMAGE_TAG}"
  echo "IMAGE_NAME: ${IMAGE_NAME}"
  
  echo "-----------------------------------"
  echo "CI_COMMIT_SHORT_SHA: ${CI_COMMIT_SHORT_SHA}"
  echo "CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}"
  echo "CI_PROJECT_URL: ${CI_PROJECT_URL}"
  
  echo "-----------------------------------"
  echo "HELM_CHART_PATH: ${HELM_CHART_PATH}"
  echo "HELM_DRY_RUN: ${HELM_DRY_RUN}"
  echo "HELM_BASE_VALUES: ${HELM_BASE_VALUES}"
fi

[ -z "$GCLOUD_PROJECT_ID" ] && { echo "GCLOUD_PROJECT_ID is required"; exit 1; }
[ -z "$GCLOUD_SA_KEY" ] && { echo "GCLOUD_SA_KEY is required"; exit 1; }
[ -z "$GCLOUD_GKE_CLUSTER_NAME" ] && { echo "GCLOUD_GKE_CLUSTER_NAME is required"; exit 1; }
[ -z "$GCLOUD_GKE_ZONE" ] && { echo "GCLOUD_GKE_ZONE is required"; exit 1; }
[ -z "$GCLOUD_GKE_NAMESPACE" ] && { echo "GCLOUD_GKE_NAMESPACE is required"; exit 1; }

[ -z "$HELM_BASE_VALUES" ] && { echo "HELM_BASE_VALUES is required"; exit 1; }
[ -z "$HELM_CHART_PATH" ] && { echo "HELM_CHART_PATH is required"; exit 1; }

[ -z "$PROJECT_NAME" ] && { echo "PROJECT_NAME is required"; exit 1; }
[ -z "$APP_NAME" ] && { echo "APP_NAME is required"; exit 1; }
[ -z "$IMAGE_TAG" ] && { echo "IMAGE_TAG is required"; exit 1; }
[ -z "$IMAGE_NAME" ] && { echo "IMAGE_NAME is required"; exit 1; }

# CI_ENVIRONMENT_NAME: should be defined by CI/CD tool
# CI_COMMIT_REF_NAME: should be defined by CI/CD tool
# CI_COMMIT_SHORT_SHA: should be defined by CI/CD tool
# CI_PROJECT_URL: should be defined by CI/CD tool

# Notify about success
echo "Everything is silky smooth, well done!"
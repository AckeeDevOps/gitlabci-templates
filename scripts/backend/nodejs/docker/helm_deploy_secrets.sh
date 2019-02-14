#!/bin/sh

# set defaults
[ -z "$HELM_DRY_RUN" ] && { export HELM_DRY_RUN=false; }

echo "script version: v1.1.0"
echo "upgrading release ${PROJECT_NAME}-${APP_NAME}-${CI_ENVIRONMENT_NAME} in namespace ${GCLOUD_GKE_NAMESPACE} ..."
echo "--------------------------------------------------------------"
echo "remote image name: eu.gcr.io/${GCLOUD_PROJECT_ID}/${PROJECT_NAME}/${APP_NAME}"
echo "--> eu.gcr.io/${GCLOUD_PROJECT_ID}/${PROJECT_NAME}/${APP_NAME}-${CI_COMMIT_REF_NAME}:${CI_COMMIT_SHORT_SHA}"
echo "--------------------------------------------------------------"
echo "Helm release: ${PROJECT_NAME}-${APP_NAME}-${CI_ENVIRONMENT_NAME}"
echo "--------------------------------------------------------------"

# Show executed command
set -x

helm upgrade \
--install \
-f ${HELM_BASE_VALUES} \
-f ${VAULTIER_SECRET_OUTPUT_PATH} \
--set general.appName=${APP_NAME} \
--set general.projectName=${PROJECT_NAME} \
--set general.environment=${CI_ENVIRONMENT_NAME} \
--set general.imageName=eu.gcr.io/${GCLOUD_PROJECT_ID}/${PROJECT_NAME}/${APP_NAME}-${CI_COMMIT_REF_NAME} \
--set general.imageTag=${IMAGE_TAG} \
--set general.meta.buildHash=${CI_COMMIT_SHORT_SHA} \
--set general.meta.branch=${CI_COMMIT_REF_NAME} \
--set general.meta.repositoryUrl=${CI_PROJECT_URL} \
--set general.gcpProjectId=${GCLOUD_PROJECT_ID} \
--namespace=${GCLOUD_GKE_NAMESPACE} \
--dry-run=${HELM_DRY_RUN} \
${PROJECT_NAME}-${APP_NAME}-${CI_ENVIRONMENT_NAME} \
${HELM_CHART_PATH}

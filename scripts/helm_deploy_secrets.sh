#!/bin/sh

echo "script version: v1.0.0"
echo "upgrading release ${IMAGE_NAME} in namespace ${GCLOUD_GKE_NAMESPACE} ..."

echo "--------------------------------------------------------------"
echo "APP_NAME: ${APP_NAME}"
echo "PROJECT_NAME: ${PROJECT_NAME}"
echo "CI_ENVIRONMENT_NAME: ${CI_ENVIRONMENT_NAME}"
echo "IMAGE_TAG: ${IMAGE_TAG}"
echo "CI_COMMIT_SHORT_SHA: ${CI_COMMIT_SHORT_SHA}"
echo "CI_COMMIT_REF_NAME: ${CI_COMMIT_REF_NAME}"
echo "CI_PROJECT_URL: ${CI_PROJECT_URL}"
echo "GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID}"
echo "GCLOUD_GKE_NAMESPACE: ${GCLOUD_GKE_NAMESPACE}"
echo "HELM_CHART_PATH: ${HELM_CHART_PATH}"
echo "--------------------------------------------------------------"
echo "remote image name: eu.gcr.io/${GCLOUD_PROJECT_ID}/${PROJECT_NAME}/${APP_NAME}"
echo "--> eu.gcr.io/${GCLOUD_PROJECT_ID}/${PROJECT_NAME}/${APP_NAME}:${CI_COMMIT_SHORT_SHA}"
echo "--------------------------------------------------------------"
echo "Helm release: ${PROJECT_NAME}-${APP_NAME}-${CI_ENVIRONMENT_NAME}"
echo "--------------------------------------------------------------"

helm upgrade \
  --install \
  -f ${HELM_BASE_VALUES} \
  -f ${PLUGIN_SECRET_OUTPUT_PATH} \
  --set general.appName=${APP_NAME} \
  --set general.projectName=${PROJECT_NAME} \
  --set general.environment=${CI_ENVIRONMENT_NAME} \
  --set general.imageName=eu.gcr.io/${GCLOUD_PROJECT_ID}/${PROJECT_NAME}/${APP_NAME} \
  --set general.imageTag=${IMAGE_TAG} \
  --set general.meta.buildHash=${CI_COMMIT_SHORT_SHA} \
  --set general.meta.branch=${CI_COMMIT_REF_NAME} \
  --set general.meta.repositoryUrl=${CI_PROJECT_URL} \
  --set general.gcpProjectId=${GCLOUD_PROJECT_ID} \
  --namespace=${GCLOUD_GKE_NAMESPACE} \
  --dry-run=false \
  ${PROJECT_NAME}-${APP_NAME}-${CI_ENVIRONMENT_NAME} \
  ${HELM_CHART_PATH}

# Example pipeline

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/fetch.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/test.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/build.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/deploy.yml

# list of stages
stages:
  - fetch
  - test
  - build
  - deploy

cache:
  key: "${CI_JOB_NAME}-${CI_COMMIT_REF_SLUG}"
  untracked: true

variables:
  ### GLOBAL STUFF
  APP_NAME: api
  PROJECT_NAME: node-template
  GIT_STRATEGY: clone
  IMAGE_NAME: ${PROJECT_NAME}-${APP_NAME}-${CI_COMMIT_REF_NAME}
  IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}
  HELM_CHART_PATH: helm/charts/default
  
  ### DEVELOPMENT environment
  GCLOUD_PROJECT_ID_DEVELOPMENT: project-123
  GCLOUD_GKE_CLUSTER_DEVELOPMENT: development
  GCLOUD_GKE_NAMESPACE_DEVELOPMENT: default
  GCLOUD_GKE_ZONE_DEVELOPMENT: europe-west3-c
  
  ### STAGE environment
  GCLOUD_PROJECT_ID_STAGE: project-123
  GCLOUD_GKE_CLUSTER_STAGE: stage
  GCLOUD_GKE_NAMESPACE_STAGE: default
  GCLOUD_GKE_ZONE_STAGE: europe-west3-c
  
  ### PRODUCTION environment
  GCLOUD_PROJECT_ID_PRODUCTION: project-123
  GCLOUD_GKE_CLUSTER_PRODUCTION: production
  GCLOUD_GKE_NAMESPACE_PRODUCTION: default
  GCLOUD_GKE_ZONE_PRODUCTION: europe-west3-c
  
  ### VAULTIER settings
  VAULTIER_VAULT_ADDR: https://vault.co.uk
  VAULTIER_VAULT_TOKEN: ${VAULT_TOKEN}
  VAULTIER_BRANCH: ${CI_COMMIT_REF_NAME}

  ### AGLIO UPLOADER settings
  AGLIO_DOCS_DIRECTORY: ./docs-output/.
  GCS_BUKET: your.bucket.co.uk
  GCS_PREFIX: /node-template/${CI_COMMIT_REF_NAME}/
  
  ### SOFTWARE VERSIONS
  VAULTIER_RELEASE_LINK: https://github.com/AckeeDevOps/vaultier/releases/download/v1.0.2/vaultier-v1.0.2
  HELMER_IMAGE: ackee/helmer-gke:v1.0.0
  DOCKER_GCR_IMAGE: ackee/docker-gcr:v0.0.5
  NODE_IMAGE: node:10.14.0 # Please also change in Dockerfile

  # PLEASE DON'T FORGET
  # specify following values in CI / CD settings!
  # VAULT_TOKEN
  # GCLOUD_SA_KEY
  # SSH_KEY
  
  # WHEN TESTING, set
  # HELM_DRY_RUN to "true"

### MERGE REQUEST pipeline
fetch:mr:
  extends: .fetchNodeJsModules
  only: ["merge_requests"]

test:mr:
  extends: .ciTestSecrets
  only: ["merge_requests"]

lint:mr:
  extends: .ciLint
  only: ["merge_requests"]

documentation:mr:
  extends: .aglioDocsUpload
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
  only: ["merge_requests"]

### DELIVERY / DEPLOYMENT pipeline
fetch:delivery:
  extends: .fetchNodeJsModules
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

test:delivery:
  extends: .ciTestSecrets
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

lint:delivery:
  extends: .ciLint
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

documentation:delivery:
  extends: .aglioDocsUpload
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

build:delivery:production:
  extends: .buildDockerBranchMaster
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_PRODUCTION}

deploy:delivery:production:
  extends: .deployBranchMasterSecrets
  variables:
    # Helm values file
    HELM_BASE_VALUES: helm/values/production.yaml
```

# Prefabs for container-based (Docker) backend apps

## Example pipelines

### Pipeline for Deployment and Merge Requests

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/docker/build.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/docker/test.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/docker/deploy.yml

# list of stages
stages:
  - test
  - build
  - deploy

variables:
  ### GLOBAL STUFF
  APP_NAME: api
  PROJECT_NAME: node-template
  GIT_STRATEGY: clone
  TZ: Europe/Prague
  IMAGE_NAME: ${PROJECT_NAME}-${APP_NAME}-${CI_COMMIT_REF_NAME}
  IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}
  HELM_CHART_PATH: helm/charts/default
  
  ### DEVELOPMENT environment
  GCLOUD_PROJECT_ID_DEVELOPMENT: my-project-id
  GCLOUD_GKE_CLUSTER_DEVELOPMENT: development
  GCLOUD_GKE_NAMESPACE_DEVELOPMENT: default
  GCLOUD_GKE_ZONE_DEVELOPMENT: europe-west3-c
  
  ### STAGE environment
  GCLOUD_PROJECT_ID_STAGE: my-project-id
  GCLOUD_GKE_CLUSTER_STAGE: stage
  GCLOUD_GKE_NAMESPACE_STAGE: default
  GCLOUD_GKE_ZONE_STAGE: europe-west3-c
  
  ### PRODUCTION environment
  GCLOUD_PROJECT_ID_PRODUCTION: my-project-id
  GCLOUD_GKE_CLUSTER_PRODUCTION: production
  GCLOUD_GKE_NAMESPACE_PRODUCTION: default
  GCLOUD_GKE_ZONE_PRODUCTION: europe-west3-c

  ### GCLOUD Service Account key
  GCLOUD_SA_KEY: ${SECRET_GCLOUD_SA_KEY}        # comes from ci/cd settings

  ### RSA private key
  SSH_KEY: ${SECRET_SSH_KEY}                    # comes from ci/cd settings
  
  ### VAULTIER settings
  VAULTIER_VAULT_ADDR: https://vault.co.uk
  VAULTIER_VAULT_TOKEN: ${SECRET_VAULT_TOKEN}   # comes from ci/cd settings
  VAULTIER_BRANCH: ${CI_COMMIT_REF_NAME}

  ### AGLIO UPLOADER settings
  AGLIO_DOCS_DIRECTORY: ./docs-output/.
  GCS_BUKET: your-bucket-name
  GCS_PREFIX: /node-template/${CI_COMMIT_REF_NAME}/
  
  ### SOFTWARE VERSIONS
  AGLIO_UPLOADER_IMAGE: ackee/aglio-uploader:v1.2.2
  VAULTIER_RELEASE_LINK: https://github.com/AckeeDevOps/vaultier/releases/download/v1.0.2/vaultier-v1.0.5
  HELMER_IMAGE: ackee/helmer-gke:v1.0.0
  DOCKER_GCR_IMAGE: ackee/docker-gcr:v0.0.5
  NODE_IMAGE: node:10.14.0 # Please also change in Dockerfile

### MERGE REQUEST pipeline
test:mr:                                        # stage: test, comes from included test.yml
  extends: .ciTestSecrets
  only: ["merge_requests"]

lint:mr:                                        # stage: test, comes from included test.yml
  extends: .ciLint
  only: ["merge_requests"]

documentation:mr:                               # stage: build, comes from included build.yml
  extends: .aglioDocsUpload
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
  only: ["merge_requests"]

### DELIVERY / DEPLOYMENT pipeline
test:delivery:                                  # stage: test, comes from included test.yml
  extends: .ciTestSecrets
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

lint:delivery:                                  # stage: test, comes from included test.yml
  extends: .ciLint
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

build:production:                               # stage: build, comes from included build.yml
  extends: .buildDockerBranchMaster
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_PRODUCTION}

documentation:delivery:                         # stage: build, comes from included build.yml
  extends: .aglioDocsUpload
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

deploy:production:                              # deploy: build, comes from included deploy.yml
  extends: .deployBranchMasterSecrets
  variables:
    HELM_BASE_VALUES: helm/values/production.yaml
```

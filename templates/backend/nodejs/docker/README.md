# Prefabs for container-based (Docker) backend apps

These prefabs are meant to be used during with Dockerized workloads hosted on top of Google GKE. 
Hence we use Google Container Registry and other products from GCP portfolio. These bits most likely 
won't fit your needs precisely but you can fork this repo and adjust them by your needs.

## General requirements
- `deploy` and `test` prefabs require base64 encoded RSA private key 
in the variable `SSH_KEY`

## Implemented prefabs

**`.buildDockerBranchDevelopment`** builds and uploads Docker images from the `development` branch. This job 
is built around [Ackee/docker-gcr](https://github.com/AckeeDevOps/docker-gcr) Docker image.

Sample Dockerfile might look as follows:

```dockerfile
ARG SSH_KEY=""
ARG BUILD_IMAGE="node:10.14.0"

FROM ${BUILD_IMAGE} as builder
ENV JOBS="max"
WORKDIR /usr/src/app
COPY . .
RUN mkdir ~/.ssh/
RUN echo $SSH_KEY | base64 -d > ~/.ssh/id_rsa
RUN chmod 0400 ~/.ssh/id_rsa
RUN eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa
RUN echo 'Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null' > ~/.ssh/config
RUN npm set unsafe-perm=true
RUN npm set progress=false
RUN npm set loglevel=error
RUN npm ci

FROM ${BUILD_IMAGE}
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app /usr/src/app
CMD ["npm", "start"]
```

**`.buildDockerBranchStage`** same as `.buildDockerBranchDevelopment` but it builds `stage` branch.

**`.buildDockerBranchMaster`** same as `.buildDockerBranchDevelopment` but it builds `master` branch.

**`.aglioDocsUploadDelivery`** is job built around [Ackee/aglio-uploader](https://github.com/AckeeDevOps/aglio-uploader) 
Docker image. It contains a few third-party tools, namely: `aglio`, `apib2swagger`, `swagger-gen`, `html-inline` 
and `rclone`. This step basically executes `npm run docs` command and uploads rendered bits to the GCS bucket. This particular job is 
triggered after push to the `development`, `stage` and `master` 
branches.

**`.aglioDocsUploadMergeRequest`** same as `.aglioDocsUploadDelivery` 
but for Merge Request events.

Sample NPM script might look as follows:

```json
...
"docs": "aglio -i ./docs/api/api.apib -c -o ./docs/api/all.apib && apib2swagger --prefer-reference --bearer-apikey -i ./docs/api/all.apib -o ./docs/api/swagger.json && swagger-gen -d docs-temp ./docs/api/swagger.json && html-inline -i ./docs-temp/index.html -o ./docs-output/index.html -b ./docs-temp",
...
```

**`.ciTestSecrets`** performs `npm run ci-test` with secrets injected, `only` directive has to be specified in 
the main pipeline file. Secrets injection is handled via [Vaultier](https://github.com/AckeeDevOps/vaultier) tool

Sample secrets specification:

```yaml
---
branches:
  - name: master
    secrets:
      - path: secret/data/path/to/production/document
        keyMap:
          - vaultKey: SQL_HOST
            localKey: SQL_HOST
  - name: stage
    secrets:
      - path: secret/data/path/to/stage/document
        keyMap:
          - vaultKey: SQL_HOST
            localKey: SQL_HOST
  - name: development
    secrets:
      - path: secret/data/path/to/development/document
        keyMap:
          - vaultKey: SQL_HOST
            localKey: SQL_HOST

testConfig:
  secrets:
    - path: secret/data/path/to/test/document
      keyMap:
        - vaultKey: SQL_HOST
          localKey: SQL_HOST

```

**`.ciTestNoSecrets`** performs `npm run ci-test` with, `only` directive has to be specified in the main pipeline file.

**`.ciLint`** performs `npm run ci-lint` with, `only` directive has to be specified in the main pipeline file.

**`.deployBranchSecretsMaster`** deploys application (from `master` branch) to the production GKE environment using Helm. 
This job is built around [Ackee/helmer-gke](https://github.com/AckeeDevOps/helmer-gke) which contains Helm 
binary and also simplifies GKE authentication. Please note 
this is manual task so it has to be confirmed from Gitlab interface.

**`.deployBranchSecretsStage`** deploys application (from `stage` branch) to the stage GKE environment using Helm. 
This job is built around [Ackee/helmer-gke](https://github.com/AckeeDevOps/helmer-gke) which contains Helm 
binary and also simplifies GKE authentication. Please note 
this is manual task so it has to be confirmed from Gitlab interface.

**`.deployBranchSecretsDevelopment`** deploys application (from `development` branch) to the stage GKE environment using Helm. 
This job is built around [Ackee/helmer-gke](https://github.com/AckeeDevOps/helmer-gke) which contains Helm 
binary and also simplifies GKE authentication. Deployment is done 
automatically. 

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
test:mr:                                        # stage: test
  extends: .ciTestSecretsMergeRequest

lint:mr:                                        # stage: test
  extends: .ciLintMergeRequest

documentation:mr:                               # stage: build
  extends: .aglioDocsUploadMergeRequest
  

### DELIVERY / DEPLOYMENT pipeline
test:delivery:                                  # stage: test
  extends: .ciTestSecretsDelivery

lint:delivery:                                  # stage: test
  extends: .ciLintDelivery

build:production:                               # stage: build
  extends: .buildDockerBranchMaster

documentation:delivery:                         # stage: build
  extends: .aglioDocsUploadDelivery

deploy:production:                              # stage: deploy
  extends: .deployBranchSecretsMaster
```

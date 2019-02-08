# Prefabs for container-based (Docker) backend apps

These prefabs are meant to be used during with Dockerized workloads hosted on top of Google GKE. 
Hence we use Google Container Registry and other products from GCP portfolio. These bits most likely 
won't fit your needs precisely but you can fork this repo and adjust them by your needs.

## General requirements
- `deploy` and `test` prefabs require base64 encoded RSA private key 
in the variable `SSH_KEY`

## Implemented prefabs

**`.buildDockerBranchDevelopment`** builds and uploads Docker images from the `development` branch. This job 
is built around [Ackee/docker-gcr](https://github.com/AckeeDevOps/docker-gcr) Docker image. It requires a few 
configuration parameters (specify them in `variables` section): 

- `GCLOUD_SA_KEY`: base64 encoded Service Account key - this property is strictly required by Ackee/docker-gcr
- `SSH_KEY`: base64 encoded RSA private key, it's mainly used for private git repositories
- `IMAGE_NAME`: name of the *local* Docker image, this property will be assigned to `-t` flag during `docker build` phase
- `IMAGE_TAG`: tag for the *local* Docker image (see above), this property will be assigned to `-t` flag during `docker build` phase
- `BUILD_IMAGE`: base image for your Docker build e.g. `node:10.14.2`
- `PROJECT_NAME`: project friendly name e.g. name of the customer
- `APP_NAME`: name of the current micro service e.g. `api`
- `GCLOUD_PROJECT_ID`: GCP project id where you Docker image will be uploaded to

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

**`.aglioDocsUpload`** is job built around [Ackee/aglio-uploader](https://github.com/AckeeDevOps/aglio-uploader) 
Docker image. It contains a few third-party tools, namely: `aglio`, `apib2swagger`, `swagger-gen`, `html-inline` 
and `rclone`. This step basically executes `npm run docs` command and uploads rendered bits to the GCS bucket. 
It requires a few configuration parameters (specify them in `variables` section): 

- `GCLOUD_PROJECT_ID`: GCP project id where your GCS bucket lives
- `GCLOUD_SA_KEY`: base64 encoded Service Account key - this property is strictly required by Ackee/docker-gcr
- `AGLIO_DOCS_DIRECTORY`: output directory with rendered html files, you can use relative or absolute paths.
- `GCS_BUKET`: name of the GCS bucket
- `GCS_PREFIX`: use this property to create directory structure, it's useful when you're using single GCS bucket for 
multiple projects

Sample NPM script might look as follows:

```json
...
"docs": "aglio -i ./docs/api/api.apib -c -o ./docs/api/all.apib && apib2swagger --prefer-reference --bearer-apikey -i ./docs/api/all.apib -o ./docs/api/swagger.json && swagger-gen -d docs-temp ./docs/api/swagger.json && html-inline -i ./docs-temp/index.html -o ./docs-output/index.html -b ./docs-temp",
...
```

**`.ciTestSecrets`** performs `npm run ci-test` with secrets injected, `only` directive has to be specified in 
the main pipeline file. Secrets injection is handled via [Vaultier](https://github.com/AckeeDevOps/vaultier) tool, 
this tool requires secrets specification and set of configuration properties:

- `VAULTIER_VAULT_ADDR`: full url of your vault instance e.g. `https://vault.co.uk`
- `VAULTIER_VAULT_TOKEN`: Vault token in plain text
- `VAULTIER_BRANCH`: name of the current branch, Vaultier use this property to filter the input file
- `VAULTIER_SECRET_SPECS_PATH`: path of the specification file, Vaultier use `secrets.yaml` if not specified
- `VAULTIER_RUN_CAUSE`: Vaultier use this property to filter the input file, it can be `test` or `delivery`
- `VAULTIER_OUTPUT_FORMAT`: `dotenv` or `helm`, see [Vaultier](https://github.com/AckeeDevOps/vaultier) documentation 
for further details
- `VAULTIER_SECRET_OUTPUT_PATH`: output path

The job itself also requires following property:

- `VAULTIER_RELEASE_LINK`: full link to the current Vaultier release e.g. `https://github.com/vranystepan/vaultier/releases/download/v0.0.4/vaultier-v0.0.5`

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

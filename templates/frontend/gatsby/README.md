# Gitlab CI bits for Gatsby

These simple build step prefabs are meant to be used with [Gatsby](https://www.gatsbyjs.org/) 
and [Google Cloud Storage](https://cloud.google.com/storage/) (used as content hosting). 

please note that bits from build stage (`gatsbyBuildDevelopment`, `gatsbyBuildStage`, `gatsbyBuildMaster`) 
are shipped to the next stage (`gatsbyDeployDevelopment`, `gatsbyDeployStage`, `gatsbyDeployMaster`) 
via Gitlab CI artifacts so deployment prefabs can't be run independently.

## Requirements

### Nodejs configuration
`package.json` should contain `build` script e.g

```json
"build": "gatsby build",
```

### Gatsby configuration
Please make sure that Gatsby output directory is always `public`.

## Example gitlab-ci.yml

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/frontend/gatsby/build.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/frontend/gatsby/deploy.yml

stages:
  - build
  - deploy

variables:
  DEFAULT_GCS_BUCKET_REGION: europe-west3
  DEFAULT_GCS_INDEX_FILE: index.html
  DEFAULT_GCS_E404_FILE: index.html

# DEVELOPMENT steps
build:development:
  image: node:8
  extends: .gatsbyBuildDevelopment
  variables:
    SSH_KEY: ${SECRET_SSH_KEY}

deploy:development:
  extends: .gatsbyDeployDevelopment
  variables:
    GCLOUD_SA_KEY: ${SECRET_GCLOUD_SA_KEY}
    GCLOUD_PROJECT_ID: gcp-project-123
    GCS_BUCKET_REGION: ${DEFAULT_GCS_BUCKET_REGION}
    GCS_BUCKET_NAME: your.dev.bucket.name
    GCS_INDEX_FILE: ${DEFAULT_GCS_INDEX_FILE}
    GCS_E404_FILE: ${DEFAULT_GCS_E404_FILE}
```

## Configuration of prefabs

### gatsbyBuildDevelopment, gatsbyBuildStage, gatsbyBuildMaster

**`gatsbyBuildDevelopment`** is invoked only after push to `development`

**`gatsbyBuildStage`** is invoked only after push to `stage`

**`gatsbyBuildMaster`** is invoked only after push to `master`

| variable | description | example | required |
| -------- | ----------- | ------- | -------- |
| SSH_KEY | Base64 encoded RSA private key for accessing private NPM modules | | `true` |

### gatsbyDeployDevelopment, gatsbyDeployStage, gatsbyDeployMaster


**`gatsbyDeployDevelopment`** is invoked only after push to `development`

**`gatsbyDeployStage`** is invoked only after push to `stage`

**`gatsbyDeployMaster`** is invoked only after push to `master`

| variable | description | example | required |
| -------- | ----------- | ------- | -------- |
| GCLOUD_SA_KEY | Base64 encoded GCP Service Account key (JSON) |  | `true` |
| GCLOUD_PROJECT_ID | project id of target GCP project, note that project id is not always the same as project name | | `true` |
| GCS_BUCKET_REGION | [location](https://cloud.google.com/storage/docs/locations) of newly created GCS bucket | `europe-west3` | `true` |
| GCS_BUCKET_NAME | full name of target GCS bucket | `your.dev.bucket.name` | `true` |
| GCS_INDEX_FILE | name of the file which will act as index page | `index.html` | `true` |
| GCS_E404_FILE | name of the file which will act as error page | `e404.html` | `true` |

### gatsbyBuildDockerDevelopment, gatsbyBuildDockerStage, gatsbyBuildDockerMaster
TBD

### gatsbyBuildDockerSecretsDevelopment, gatsbyBuildDockerSecretsStage, gatsbyBuildDockerSecretsMaster
TBD

### gatsbyDeployGkeDevelopment, gatsbyDeployGkeStage, gatsbyDeployGkeMaster

| variable | description | example | required |
| -------- | ----------- | ------- | -------- |
| GCLOUD_SA_KEY | Base64 encoded Service Account Key (JSON) |
| GCLOUD_PROJECT_ID |
| GKE_CLUSTER |
| GKE_ZONE |
| GKE_NAMESPACE |
| HELM_BINARIES_URL |
| HELM_REPOSITORY_URL |
| HELM_REPOSITORY_NAME |
| HELM_REPOSITORY_USERNAME |
| HELM_REPOSITORY_PASSWORD |
| HELM_RELEASE_NAME |
| HELM_CHART_NAME |
| HELM_VALUES_FILE |
| IMAGE_NAME |
| IMAGE_TAG |
| APP_NAME |
| PROJECT_NAME |
| RUNTIME_ENVIRONMENT |
| HELM_CHART_VERSION |
| HELM_FORCE_UPGRADE |

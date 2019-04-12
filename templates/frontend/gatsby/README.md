# Gitlab CI bits for Gatsby

These simple build step prefabs are meant to be used with [Gatsby](https://www.gatsbyjs.org/) 
and [Google Cloud Storage](https://cloud.google.com/storage/) (used as content hosting).

## Requirements

### Nodejs configuration
`package.json` should contain `build` script e.g

```json
"build": "gatsby build",
```

### Gatsby configuration
Please make sure that Gatsby output directory is always `public`.

### Gitlab configuration
Please make sure you have configured following variables in CI/CD settings:

**`SECRET_SSH_KEY`**: base64 encoded RSA private key e.g. `cat ~/.ssh/id_rsa | base64 -w0`

In the example below we use different Service Account keys for each environment hence 
we have two secrets with Google Service Account keys.

**`SECRET_GCLOUD_SA_KEY_DEVELOPMENT`**: base64 encoded GCP Service Account key

**`SECRET_GCLOUD_SA_KEY_PRODUCTION`**: base64 encoded GCP Service Account key

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

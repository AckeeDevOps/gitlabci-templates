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
  ### SECRETS
  SSH_KEY: ${SECRET_SSH_KEY}
  GCLOUD_SA_KEY_DEVELOPMENT: ${SECRET_GCLOUD_SA_KEY_DEVELOPMENT}
  GCLOUD_SA_KEY_PRODUCTION: ${SECRET_GCLOUD_SA_KEY_PRODUCTION}

  ### GCP PROJECTS
  GCLOUD_PROJECT_ID_DEVELOPMENT: gcp-project-1234
  GCLOUD_PROJECT_ID_PRODUCTION: gcp-project-5678

  ### GCS BUCKETS
  GCS_BUCKET_NAME_DEVELOPMENT: dev.my-fancy-domain.com
  GCS_BUCKET_NAME_PRODUCTION: prod.my-fancy-domain.com

  ### GCS BUCKETS LOCATIONS
  GCS_BUCKET_REGION_DEVELOPMENT: europe-west3
  GCS_BUCKET_REGION_PRODUCTION: europe-west3
  
  ### MICCELLANEOUS
  GCS_INDEX_FILE: index.html
  GCS_E404_FILE: index.html
  NODE_IMAGE: node:8

# DEVELOPMENT steps
build:development:
  extends: .gatsbyBuildDevelopment

deploy:development:
  extends: .gatsbyDeployDevelopment
  
# PRODUCTION steps
build:production:
  extends: .gatsbyBuildMaster

deploy:production:
  extends: .gatsbyDeployMaster

```


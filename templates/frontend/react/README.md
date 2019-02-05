# Example pipeline

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/frontend/react/test.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/frontend/react/build.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/frontend/react/deploy.yml

stages:
  - test
  - build
  - deploy

variables:
  ### GCP details
  GCLOUD_PROJECT_ID_DEVELOPMENT: dev-project-123
  GCLOUD_PROJECT_ID_STAGE: stage-project-456
  GCLOUD_PROJECT_ID_PRODUCTION: prod-project-789

  ### GCS details
  BUCKET_URL_DEVELOPMENT: gs://dev.yourdomain.co.uk
  BUCKET_URL_STAGE: gs://stage.yourdomain.co.uk
  BUCKLET_URL_PRODUCTION: gs://prod.yourdomain.co.uk

  ### BUILD commands
  BUILD_COMMAND_DEVELOPMENT: npm install && npm run build:dev
  BUILD_COMMAND_STAGE: npm install && npm run build:stage
  BUILD_COMMAND_PRODUCTION: npm install && npm run build:prod

  ## BUILD output
  BUILD_DIRECTORY_DEVELOPMENT: build
  BUILD_DIRECTORY_STAGE: build
  BUILD_DIRECTORY_PRODUCTION: build

  ### SOFTWARE versions
  NODE_IMAGE: node:8

# TEST for merge requests
test:mr:
  extends: .ciTest
  only: ["merge_requests"]

lint:mr:
  extends: .ciLint
  only: ["merge_requests"]

# TEST for master, stage and development
test:delivery:
  extends: .ciTest
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["development", "stage", "master"]

lint:delivery:
  extends: .ciLint
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["development", "stage", "master"]

# DEVELOPMENT
build:development:
  extends: .buildBranch
  variables:
    BUILD_COMMAND_CURRENT: ${BUILD_COMMAND_DEVELOPMENT}
    BUILD_DIRECTORY_CURRENT: ${BUILD_DIRECTORY_DEVELOPMENT}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["development"]

deploy:development:
  extends: .deployBranch
  variables:
    BUILD_DIRECTORY_CURRENT: ${BUILD_DIRECTORY_DEVELOPMENT}
    GCLOUD_PROJECT_ID_CURRENT: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
    BUCKET_URL_CURRENT: ${BUCKET_URL_DEVELOPMENT}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["development"]

# STAGE
build:stage:
  extends: .buildBranch
  variables:
    BUILD_COMMAND_CURRENT: ${BUILD_COMMAND_STAGE}
    BUILD_DIRECTORY_CURRENT: ${BUILD_DIRECTORY_STAGE}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["stage"]

deploy:stage:
  extends: .deployBranch
  variables:
    BUILD_DIRECTORY_CURRENT: ${BUILD_DIRECTORY_STAGE}
    GCLOUD_PROJECT_ID_CURRENT: ${GCLOUD_PROJECT_ID_STAGE}
    BUCKET_URL_CURRENT: ${BUCKET_URL_STAGE}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["stage"]

# PRODUCTION
build:production:
  extends: .buildBranch
  variables:
    BUILD_COMMAND_CURRENT: ${BUILD_COMMAND_PRODUCTION}
    BUILD_DIRECTORY_CURRENT: ${BUILD_DIRECTORY_PRODUCTION}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master"]

deploy:production:
  extends: .deployBranch
  variables:
    BUILD_DIRECTORY_CURRENT: ${BUILD_DIRECTORY_PRODUCTION}
    GCLOUD_PROJECT_ID_CURRENT: ${GCLOUD_PROJECT_ID_PRODUCTION}
    BUCKET_URL_CURRENT: ${BUCKET_URL_PRODUCTION}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master"]
```

# Prefabs for Firebase Cloud Function

These prefabs are meant to be used during with 
Firebase Cloud Functions. They rely on following 
directory structure:

```
.
├── docs
├── docs-output
│   └── placeholder.html
├── firebase.json
├── functions
│   ├── package.json
│   ├── src
│   │   ├── api.ts
│   │   └── index.ts
│   ├── tsconfig.json
│   └── tslint.json
├── README.md
├── secrets.yaml
├── .gitlab-ci.yml
├── .firebaserc
```

## General requirements
- `deploy` and `test` prefabs require base64 encoded RSA private key 
in the variable `SSH_KEY`

## Implemented prefabs

> please note all `npm` commands are executed in the `functions` 
> directory. 

**`.deployBranchMasterSecrets`** deploys Firebase function with secrets injected on push to `master` branch, this prefab can be 
used directly without specifying `only` directive. Npm script 
`deploy-production` has to be specified.

**`.deployBranchDevelopmentSecrets`** deploys Firebase function with secrets injected on push to `development` branch, this prefab can be 
used directly without specifying `only` directive. Npm script 
`deploy-dev` has to be specified.

**`.deployBranchStageSecrets`** deploys Firebase function with secrets injected on push to `stage` branch, this prefab can be 
used directly without specifying `only` directive. Npm script 
`deploy-stage` has to be specified.

**`aglioDocsUpload`** uploads generated documentation to the 
GCS bucket, `only` directive has to be specified in the main 
pipeline file.

**`.ciTestSecrets`** performs `npm run ci-test` with secrets 
injected, `only` directive has to be specified in the main 
pipeline file.

**`.ciLint`** performs `npm run ci-lint` with, `only` 
directive has to be specified in the main pipeline file.

**`.ciTest`** performs `npm run ci-test` with, `only` 
directive has to be specified in the main pipeline file.

## Example pipelines

### Delivery/Deployment only pipeline for 2 branches

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/6ad25c313020077cb01551a1fd68ab7596f78ced/templates/backend/nodejs/cloud_functions/deploy.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/6ad25c313020077cb01551a1fd68ab7596f78ced/templates/backend/nodejs/cloud_functions/documentation.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/6ad25c313020077cb01551a1fd68ab7596f78ced/templates/backend/nodejs/cloud_functions/test.yml

stages:
  - test
  - documentation
  - deploy

variables:
  APP_NAME: api
  PROJECT_NAME: my-project
  GIT_STRATEGY: clone

  ### ENVIRONEMENTS
  # development:
  GCLOUD_PROJECT_ID_DEVELOPMENT: project-dev-1234
  #production:
  GCLOUD_PROJECT_ID_PRODUCTION: project-prod-1234

  ### GCLOUD Service Account key
  GCLOUD_SA_KEY: ${SECRET_GCLOUD_SA_KEY}        # comes from ci/cd settings

  ### RSA private key
  SSH_KEY: ${SECRET_SSH_KEY}                    # comes from ci/cd settings

  ### FIREBASE token
  FIREBASE_TOKEN: ${SECRET_FIREBASE_TOKEN}      # comes from ci/cd settings

  ### VAULTIER settings (global settings)
  VAULTIER_VAULT_ADDR: https://vault.co.yk
  VAULTIER_VAULT_TOKEN: ${SECRET_VAULT_TOKEN}   # comes from ci/cd settings
  VAULTIER_BRANCH: ${CI_COMMIT_REF_NAME}

  ### AGLIO UPLOADER settings
  AGLIO_DOCS_DIRECTORY: ${CI_PROJECT_DIR}/docs-output/.
  GCS_BUKET: my-gcs-bucket-name
  GCS_PREFIX: /${PROJECT_NAME}-${APP_NAME}/${CI_COMMIT_REF_NAME}/

  ### SOFTWARE VERSIONS
  AGLIO_UPLOADER_IMAGE: ackee/aglio-uploader:v1.2.2
  VAULTIER_RELEASE_LINK: https://github.com/AckeeDevOps/vaultier/releases/download/v1.0.2/vaultier-v1.0.5
  NODE_IMAGE: node:8

### DELIVERY pipeline
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

deploy:development:
  extends: .deployBranchDevelopmentSecrets

deploy:production:
  extends: .deployBranchMasterSecrets
```

### Pipeline for Deployment and Merge Requests

This pipeline is able to deploy Cloud Functions when someone 
pushes to `development`, `stage`, `master` branches and it 
also execute tests for Merge Request events. 

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/6ad25c313020077cb01551a1fd68ab7596f78ced/templates/backend/nodejs/cloud_functions/deploy.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/6ad25c313020077cb01551a1fd68ab7596f78ced/templates/backend/nodejs/cloud_functions/documentation.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/6ad25c313020077cb01551a1fd68ab7596f78ced/templates/backend/nodejs/cloud_functions/test.yml

stages:
  - test
  - documentation
  - deploy

variables:
  APP_NAME: api
  PROJECT_NAME: my-project
  GIT_STRATEGY: clone

  ### ENVIRONEMENTS
  # development:
  GCLOUD_PROJECT_ID_DEVELOPMENT: project-dev-1234
  #production:
  GCLOUD_PROJECT_ID_PRODUCTION: project-prod-1234

  ### GCLOUD Service Account key
  GCLOUD_SA_KEY: ${SECRET_GCLOUD_SA_KEY}        # comes from ci/cd settings

  ### RSA private key
  SSH_KEY: ${SECRET_SSH_KEY}                    # comes from ci/cd settings

  ### FIREBASE token
  FIREBASE_TOKEN: ${SECRET_FIREBASE_TOKEN}      # comes from ci/cd settings

  ### VAULTIER settings (global settings)
  VAULTIER_VAULT_ADDR: https://vault.co.yk
  VAULTIER_VAULT_TOKEN: ${SECRET_VAULT_TOKEN}   # comes from ci/cd settings
  VAULTIER_BRANCH: ${CI_COMMIT_REF_NAME}

  ### AGLIO UPLOADER settings
  AGLIO_DOCS_DIRECTORY: ${CI_PROJECT_DIR}/docs-output/.
  GCS_BUKET: my-gcs-bucket-name
  GCS_PREFIX: /${PROJECT_NAME}-${APP_NAME}/${CI_COMMIT_REF_NAME}/

  ### SOFTWARE VERSIONS
  AGLIO_UPLOADER_IMAGE: ackee/aglio-uploader:v1.2.2
  VAULTIER_RELEASE_LINK: https://github.com/AckeeDevOps/vaultier/releases/download/v1.0.2/vaultier-v1.0.5
  NODE_IMAGE: node:8

### MERGE REQUESTS pipeline
test:mr:                                      # stage: test
  extends: .ciTestSecrets
  only: ["merge_requests"]

lint:mr:                                      # stage: test
  extends: .ciLint
  only: ["merge_requests"]

documentation:mr:                             # stage: documentation
  extends: .aglioDocsUpload
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
  only: ["merge_requests"]

### DELIVERY pipeline
test:delivery:                                # stage: test
  extends: .ciTestSecrets
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

lint:delivery:
  extends: .ciLint                            # stage: test
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

documentation:delivery:
  extends: .aglioDocsUpload                   # stage: documentation
  variables:
    GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID_DEVELOPMENT}
  only:
    variables:
      - $CI_PIPELINE_SOURCE == "push"
    refs: ["master", "stage", "development"]

deploy:development:
  extends: .deployBranchDevelopmentSecrets    # stage deploy

deploy:production:
  extends: .deployBranchMasterSecrets         # stage deploy
```


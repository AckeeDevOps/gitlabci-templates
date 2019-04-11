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

## Examples
```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/cloud_functions/deploy.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/cloud_functions/documentation.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/backend/nodejs/cloud_functions/test.yml

stages:
  - test
  - documentation
  - deploy

variables:
  DEFAULT_APP_NAME: app
  DEFAULT_PROJECT_NAME: project
  DEFAULT_VAULTIER_RELEASE_LINK: https://github.com/AckeeDevOps/vaultier/releases/download/v1.0.2/vaultier-v1.0.2
  DEFAULT_NODE_IMAGE: node:8
  DEFAULT_VAULT_ADDR: https://vault.vault.co.uk

### DELIVERY pipeline
# Common variables for deployment jobs
.deploymentJobVariables: &deploymentJobVariables
  VAULTIER_RELEASE_LINK: ${DEFAULT_VAULTIER_RELEASE_LINK}
  SSH_KEY: ${SECRET_SSH_KEY}
  FIREBASE_TOKEN: ${SECRET_FIREBASE_TOKEN}
  VAULTIER_VAULT_ADDR: ${DEFAULT_VAULT_ADDR}
  VAULTIER_VAULT_TOKEN: ${SECRET_VAULT_TOKEN}

# Specific pipeline jobs
test:delivery: # stage: test
  extends: .ciTestSecretsDelivery
  image: ${DEFAULT_NODE_IMAGE}
  variables:
    VAULTIER_RELEASE_LINK: ${DEFAULT_VAULTIER_RELEASE_LINK}
    SSH_KEY: ${SECRET_SSH_KEY}
    VAULTIER_VAULT_ADDR: ${DEFAULT_VAULT_ADDR}
    VAULTIER_VAULT_TOKEN: ${SECRET_VAULT_TOKEN}

lint:delivery: # stage: test
  extends: .ciLintDelivery
  image: ${DEFAULT_NODE_IMAGE}
  variables:
    SSH_KEY: ${SECRET_SSH_KEY}

documentation:delivery: # stage: documentation
  extends: .docsUploadDeployment
  image: ackee/docs-generator:v1.1.1
  variables:
    APP_NAME: ${DEFAULT_APP_NAME}
    PROJECT_NAME: ${DEFAULT_PROJECT_NAME}
    OUTPUT_DIRECTORY: ${CI_PROJECT_DIR}/docs-output/.
    GCS_BUCKET: your-gcs-bucket-name
    GCS_PREFIX: /${PROJECT_NAME}-${APP_NAME}/${CI_COMMIT_REF_NAME}/
    GCLOUD_PROJECT_ID: your-project-name
    GCLOUD_SA_KEY: ${SECRET_GCLOUD_SA_KEY}

deploy:development: # stage: deploy
  extends: .deployBranchSecretsDevelopment
  image: ${DEFAULT_NODE_IMAGE}
  variables: *deploymentJobVariables


deploy:production: # stage: deploy
  extends: .deployBranchSecretsMater
  image: ${DEFAULT_NODE_IMAGE}
  variables: *deploymentJobVariables
```
## Configuration of prefabs

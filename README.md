# Ackee Gitlab CI templates

This is just a slim collection of Gitlab CI templates (or prefabes) we use 
for integration and deployment. From version 11.4 (core edition) 
you can reuse them with the 
[include](https://docs.gitlab.com/ee/ci/yaml/#include) directive.

Please note these prefabs were tested with Gitlab 11.7.0, it might behave 
unpredictable in older version.

## Contents

### Testing prefabs

### Build prefabs 

### Deployment prefabs

## Examples

### Testing

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/extends_tests.yml

stages:
  - test  

test:
  extends: .ciTestNoSecrets

```

### Deployment

```yaml
include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/extends_deploy.yml

variables:
  PROJECT_NAME: node-template-gitlab
  APP_NAME: api
  GCLOUD_PROJECT_ID_DEVELOPMENT: project1234
  GCLOUD_GKE_CLUSTER_DEVELOPMENT: cluster01
  GCLOUD_GKE_NAMESPACE_DEVELOPMENT: default
  GCLOUD_GKE_ZONE_DEVELOPMENT: europe-west3-c
  IMAGE_NAME: ${PROJECT_NAME}-${APP_NAME}-${CI_COMMIT_REF_NAME}
  IMAGE_TAG: ${CI_COMMIT_SHORT_SHA}
  PLUGIN_VAULT_ADDR: https://vault.co.uk
  PLUGIN_VAULT_TOKEN: ${VAULT_TOKEN}
  PLUGIN_BRANCH: ${CI_COMMIT_REF_NAME}

deploy:development:
  extends: .deployBranchDevelopmentSecrets
  variables:
    # Vaultier settings
    PLUGIN_RUN_CAUSE: delivery
    PLUGIN_OUTPUT_FORMAT: helm
    PLUGIN_SECRET_OUTPUT_PATH: /tmp/secrets.json
    # Helm values file
    HELM_BASE_VALUES: helm/values/development.yaml
```

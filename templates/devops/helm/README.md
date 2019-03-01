# Prefabs for Integration / Delivery of Helm charts

## Example pipeline

```yaml
stages:
  - lint
  - upload

include:
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/devops/helm/lint.yml
  - remote: https://raw.githubusercontent.com/AckeeDevOps/gitlabci-templates/master/templates/devops/helm/upload.yml

variables:
  HELM_REPOSITORY_URL: https://chart-museum.yourdomain.co.uk/
  HELM_REPOSITORY_NAME: local-repo-name
  HELM_REPOSITORY_USERNAME: ${SECRET_HELM_REPOSITORY_USERNAME}
  HELM_REPOSITORY_PASSWORD: ${SECRET_HELM_REPOSITORY_PASSWORD}
  HELM_BINARIES_URL: https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz
  DEBUG_MODE: "true"

# For all events
lint:
  extends: .helmLint

# Only for tag events
upload:
  extends: .helmUploadTag
```

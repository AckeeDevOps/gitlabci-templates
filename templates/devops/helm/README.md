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
  DEFAULT_HELM_CHART_NAME: ackee-nodejs
  DEFAULT_HELM_REPOSITORY_URL: https://repo.co.uk/
  DEFAULT_HELM_REPOSITORY_NAME: repo
  DEFAULT_HELM_REPOSITORY_USERNAME: ${SECRET_HELM_REPOSITORY_USERNAME}
  DEFAULT_HELM_REPOSITORY_PASSWORD: ${SECRET_HELM_REPOSITORY_PASSWORD}
  DEFAULT_HELM_BINARIES_URL: https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz

# For all events
lint:
  extends: .helmLint
  variables:
    HELM_BINARIES_URL: ${DEFAULT_HELM_BINARIES_URL}
    DEBUG_MODE: "true"

# Only for tag events
upload:
  extends: .helmUploadTag
  variables:
    HELM_BINARIES_URL: ${DEFAULT_HELM_BINARIES_URL}
    HELM_CHART_NAME: ${DEFAULT_HELM_CHART_NAME}
    HELM_REPOSITORY_URL: ${DEFAULT_HELM_REPOSITORY_URL}
    HELM_REPOSITORY_NAME: ${DEFAULT_HELM_REPOSITORY_NAME}
    HELM_REPOSITORY_USERNAME: ${SECRET_HELM_REPOSITORY_USERNAME}
    HELM_REPOSITORY_PASSWORD: ${SECRET_HELM_REPOSITORY_PASSWORD}
    DEBUG_MODE: "true"
```

## Configuration of prefabs

### helmLint
| variable | description | example | required |
| -------- | ----------- | ------- | -------- |
| HELM_BINARIES_URL | url of tar.gz archive with Helm binaries | `https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz` | `true` |
| DEBUG_MODE | configures verbose output from validation | `'true'` | `false` |

### helmUploadTag
| variable | description | example | required |
| -------- | ----------- | ------- | -------- |
| HELM_BINARIES_URL | url of tar.gz archive with Helm binaries | `https://storage.googleapis.com/kubernetes-helm/helm-v2.13.0-linux-amd64.tar.gz` | `true` |
| DEBUG_MODE | configures verbose output from validation | `'true'` | `false` |
| HELM_CHART_NAME | chart display name | `ackee-nodejs` | `true` |
| HELM_REPOSITORY_URL | URL of your Chartmuseum | `https://repo.co.uk/` | `true` |
| HELM_REPOSITORY_NAME | display name of configured repository | `ackee` | `true` |
| HELM_REPOSITORY_USERNAME | login to chartmuseum | `helm` | `true` |
| HELM_REPOSITORY_PASSWORD | password to chartmuseum | `password` | `true` |


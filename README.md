# Ackee Gitlab CI templates

This is just a slim collection of Gitlab CI templates (or prefabes) we use 
for integration and deployment. From version 11.4 (core edition) 
you can reuse them with the 
[include](https://docs.gitlab.com/ee/ci/yaml/#include) directive.

Please note these prefabs were tested with Gitlab 11.7.0, it might behave 
unpredictable in older version.

## Contents

### Backend > Nodejs > Docker prefabs

Set of prefabs for Nodejs backend apps. [See details](https://github.com/AckeeDevOps/gitlabci-templates/tree/master/templates/backend/nodejs/docker).

- testing
- linting
- building of Docker images
- deployment to GKE

### Backend > Nodejs > Cloud Functions prefabs

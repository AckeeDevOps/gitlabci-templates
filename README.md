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

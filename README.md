# Ackee Gitlab CI templates

This is just a slim collection of Gitlab CI templates we use 
for integration and deployment. From version 11.4 (core edition) 
you can reuse them with the 
[include](https://docs.gitlab.com/ee/ci/yaml/#include) directive.

## Contents

### Minio cleanup job

[This template](templates/minio-cleanup.yml) should be used with folowing cache configuration:

```yaml
# cache for all steps
cache:
  key: ${CI_COMMIT_SHORT_SHA}
  paths:
    - your-dir1
    - your-dir2
```

If you put this cleanup job at the end of your pipeline - it will effectively 
delete cached content from your minio.

```yaml
variables:
  MINIO_ADDR: "http://minio:9000"
  MINIO_ACCESS_KEY: blah
  MINIO_SECRET_KEY: blahblah

cleanup:test:
  <<: *cleanup
```

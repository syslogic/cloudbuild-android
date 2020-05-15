# What it does?

 - It builds a Docker container from [Cloud Source Repositories](https://cloud.google.com/source-repositories) with [Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).
 - It then publishes the container image as `eu.gcr.io/$PROJECT_ID/cloudbuild` to the [Container Registry](https://console.cloud.google.com/gcr/images).
 - Since the `Dockerfile` runs `./gradlew build`, the API level specified in the `build.gradle` gets installed.
 - It has: OpenJDK8, Gradle wrapper, Android command-line & platform tools installed (no AVD).

# How to use it?

 - Import to [Cloud Source Repositories](https://source.cloud.google.com/repo/new) and setup a build [trigger](https://console.cloud.google.com/cloud-build/triggers) there.
 - After having successfully built it, a new container should show up below `eu.gcr.io/$PROJECT_ID/cloudbuild`.
 - It can then be referenced in another Android project's source repository's `cloudbuild.yaml`.

# Usage examples

a) This uploads the built APK file to `gs://eu.artifacts.$PROJECT_ID.appspot.com/android/`:
````
# cloudbuild.yaml

steps:

- name: eu.gcr.io/$PROJECT_ID/cloudbuild
  id: 'pull-image'
  args: ['cp', '-a', '.', '/persistent_volume']
  volumes:
  - name: data
    path: /persistent_volume

- name: gcr.io/cloud-builders/docker
  id: 'gradle-build'
  volumes:
  - name: data
    path: /persistent_volume
  args: ['run', '-v', 'data:/workspace', '--rm', 'eu.gcr.io/$PROJECT_ID/cloudbuild', '/bin/sh', '-c', 'cd /workspace && ls -la && ./gradlew mobile:assembleDebug && mv mobile/build/outputs/apk/debug/mobile-debug.apk mobile/build/outputs/apk/debug/mobile-debug-$SHORT_SHA.apk']

- name: gcr.io/cloud-builders/gsutil
  id: 'gsutil-artifacts'
  args: ['cp', '/persistent_volume/mobile/build/outputs/apk/debug/mobile-debug-$SHORT_SHA.apk', 'gs://eu.artifacts.$PROJECT_ID.appspot.com/android/']
  volumes:
  - name: data
    path: /persistent_volume

timeout: 1200s
````

b) Injecting files at build-time requires IAM `roles/secretmanager.secretAccessor` for the CloudBuild service account:
````
- name: gcr.io/cloud-builders/gcloud
  id: 'gcloud-secrets'
  entrypoint: 'bash'
  args: [ '-c', 'gcloud secrets versions access latest --secret=keystore-properties > /persistent_volume/keystore.properties' ]
  volumes:
  - name: data
    path: /persistent_volume

- name: gcr.io/cloud-builders/docker
  id: 'gradle-build'
#  waitFor: ['gcloud-secrets']
...
````

# Conclusion

- Injecting `keystore.properties` is useless, unless one would also inject `/root/.android/*.keystore` for the code signing.

- Cloud KMS could possibly provide debug & release keystore. 

# Also see

 - GitHub Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) for GitHub integration.

 - GitHub [Google Cloud Build](https://github.com/GoogleCloudBuild) (official).

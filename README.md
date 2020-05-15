# What it does?

 - It builds a Docker container from [Cloud Source Repositories](https://cloud.google.com/source-repositories) with [Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).

 - It then publishes this container as `eu.gcr.io/$PROJECT_ID/cloudbuild` to the [Container Registry](https://console.cloud.google.com/gcr/images).

 - This container has OpenJDK 8, Gradle wrapper, Android command-line & platform tools installed (no AVD yet).

# How to use it?

 - Import to [Cloud Source Repositories](https://source.cloud.google.com/repo/new) and setup a build [triggers](https://console.cloud.google.com/cloud-build/triggers) there.
 - One can also connect GitHub as an external repository (please use your own fork and not this repository):
![Screenshot 01](https://github.com/syslogic/cloudbuild-android-builder/raw/master/screenshots/screenshot_01.png)

 - After having built it, a new container should show up below `gcr.io/$PROJECT_ID/cloudbuild/android-builder`.
 - The container can then be referenced in another Android project's source repository's `cloudbuild.yaml`.
 - For example, this uploads the built APK file eg. to `gs://eu.artifacts.$PROJECT_ID.appspot.com/android/`:

````
# cloudbuild.yaml

steps:
- name: eu.gcr.io/$PROJECT_ID/cloudbuild
  args: ['cp', '-a', '.', '/persistent_volume']
  volumes:
  - name: data
    path: /persistent_volume

- name: gcr.io/cloud-builders/docker
  volumes:
  - name: data
    path: /persistent_volume
  args: ['run', '-v', 'data:/workspace', '--rm', 'eu.gcr.io/$PROJECT_ID/cloudbuild', '/bin/sh', '-c', 'cd /workspace && ./gradlew mobile:assembleDebug && mv mobile/build/outputs/apk/debug/mobile-debug.apk mobile/build/outputs/apk/debug/mobile-debug-$SHORT_SHA.apk']

- name: gcr.io/cloud-builders/gsutil
  args: ['cp', '/persistent_volume/mobile/build/outputs/apk/debug/mobile-debug-$SHORT_SHA.apk', 'gs://eu.artifacts.$PROJECT_ID.appspot.com/android/']
  volumes:
  - name: data
    path: /persistent_volume

timeout: 1200s

````

# Also see

 - GitHub Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) for GitHub integration.

 - GitHub [Google Cloud Build](https://github.com/GoogleCloudBuild) (official).

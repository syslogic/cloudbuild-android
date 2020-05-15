# What it does?

 - It builds a Docker container from [Cloud Source Repositories](https://cloud.google.com/source-repositories) with [Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).

 - It then publishes this container as `gcr.io/$PROJECT_ID/cloudbuild/android-builder` to the [Container Registry](https://console.cloud.google.com/gcr/images).

 - This container has OpenJDK 8, Gradle wrapper 5.6.4 and Android command-line & platform tools installed (no AVD yet).

# How to use it?

 - Import to [Cloud Source Repositories](https://source.cloud.google.com/repo/new) and setup a build [triggers](https://console.cloud.google.com/cloud-build/triggers) there.
 - One can also connect GitHub as an external repository (please use your own fork and not this repository):
![Screenshot 01](https://github.com/syslogic/cloudbuild-android-builder/raw/master/screenshots/screenshot_01.png)

- After having built it, a new container should show up below `gcr.io/$PROJECT_ID/cloudbuild/android-builder`.
 - The container can then be referenced in another Android project's source repository's `cloudbuild.yaml`.

For example:
````
# cloudbuild.yaml

steps:
- name: eu.gcr.io/$PROJECT_ID/cloudbuild
  entrypoint: 'bash'
  args: ['cp', '-a', '.', '/persistent_volume']
  volumes:
  - name: 'vol1'
    path: '/persistent_volume'

- name: gcr.io/cloud-builders/docker
  volumes:
  - name: 'vol1'
    path: '/persistent_volume'
  args: ['run', '-v', 'vol1:/workspace', '--rm', 'eu.gcr.io/$PROJECT_ID/cloudbuild', '/bin/sh', '-c', 'cd /workspace && ./scripts/pre_cloudbuild.sh && ./gradlew mobile:assembleDebug && ./scripts/post_cloudbuild.sh && mv mobile/build/outputs/apk/debug/mobile-debug.apk /workspace/mobile-debug-$SHORT_SHA.apk']

artifacts:
  objects:
    location: 'gs://artifacts.$PROJECT_ID.appspot.com/android/'
    paths: [ '/workspace/mobile-debug-$SHORT_SHA.apk' ]

timeout: 1200s

````

# Also see

 - GitHub Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) for GitHub integration.

 - GitHub [Google Cloud Build](https://github.com/GoogleCloudBuild) (official).

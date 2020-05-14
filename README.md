# What it does?

 - It builds a Docker container from [Cloud Source Repositories](https://cloud.google.com/source-repositories) with [Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).

 - It then publishes this container as `gcr.io/$PROJECT_ID/cloudbuild/android-builder` to the [Container Registry](https://console.cloud.google.com/gcr/images).

 - This container has OpenJDK 8, Gradle wrapper 5.6.4 and Android command-line & platform tools installed (no AVD yet).

# How to use it?

 - Import to [Cloud Source Repositories](https://source.cloud.google.com/repo/new) and setup a build-trigger there.
 - And can also setup GitHub as external repository, as this screenshot shows:
![Screenshot 01](https://github.com/syslogic/cloudbuild-android-builder/raw/master/screenshots/screenshot_01.png)

- After having build it, a new container should show up below `gcr.io/$PROJECT_ID/cloudbuild/android-builder`.
 - The container should then be referenced in another Android project's source repository's `cloudbuild.yaml`.

For example (yet untested):
````
# cloudbuild.yaml
steps:
# Set a persistent volume according to https://cloud.google.com/cloud-build/docs/build-config (search for volumes)
- name: 'android-builder'
  volumes:
  - name: 'vol1'
    path: '/persistent_volume'
  args: ['cp', '-a', '.', '/persistent_volume']

# Build APK with Gradle Image from mounted /persistent_volume using name: vol1
- name: 'gcr.io/cloud-builders/docker'
  volumes:
  - name: 'vol1'
    path: '/persistent_volume'
  args: ['run', '-v', 'vol1:/workspace', '--rm', 'gcr.io/$PROJECT_ID/cloudbuild/android-builder', '/bin/sh', '-c', 'cd /workspace && ./gradlew build']

# Push the APK Output from vol1 to your GCS Bucket with Short Commit SHA.
- name: 'gcr.io/cloud-builders/gsutil'
  volumes:
  - name: 'vol1'
    path: '/persistent_volume'
  args: ['cp', '/persistent_volume/workspace/mobile/build/outputs/apk/debug/app-debug.apk', 'gs://$BUCKET_NAME/app-debug-$SHORT_SHA.apk']

timeout: 1200s
````

# Also see

 - GitHub Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) for GitHub integration.

 - GitHub [Google Cloud Build](https://github.com/GoogleCloudBuild) (official).

# What it does?

- It builds a Docker container from [Cloud Source Repositories](https://cloud.google.com/source-repositories) with [Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).
- It then publishes the container image as `eu.gcr.io/$PROJECT_ID/cloudbuild` to the [Container Registry](https://console.cloud.google.com/gcr/images).
- Since the `Dockerfile` runs `./gradlew build`, the API level specified in the `build.gradle` gets installed.
- It has OpenJDK8, Gradle wrapper, Android command-line & platform tools (no AVD).
- It supports Cloud KMS encryption for code signing.
- It it prepared for Firebase App Distribution.

# How to use it?

 - Import to [Cloud Source Repositories](https://source.cloud.google.com/repo/new) and setup a build [trigger](https://console.cloud.google.com/cloud-build/triggers) there.

 ![Cloud Build - Screenshot 01](https://raw.githubusercontent.com/syslogic/cloudbuild-android-builder/master/screenshots/screenshot_01.png)
 - After having successfully built it, a new container should show up below `eu.gcr.io/$PROJECT_ID/cloudbuild`.
 - This container can be used <b>in another</b> Android project (or another Git branch) `cloudbuild.yaml`, in order not to build it every time. See the examples below.

# Usage examples

These usage examples assume that you already have the image in your project's private container registry.

Hostname `eu.gcr.io` (also bucket name `eu.artifacts`) can be replaced with `us.gcr.io` or `gcr.io`.

a) This uploads debug APK files to `gs://eu.artifacts.$PROJECT_ID.appspot.com/android/`:

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
  args: ['run', '-v', 'data:/workspace', '--rm', 'eu.gcr.io/$PROJECT_ID/cloudbuild', '/bin/sh', '-c', 'cd /workspace && ls -la && ./gradlew mobile:assembleDebug && mv mobile/build/outputs/apk/debug/mobile-debug.apk mobile/build/outputs/apk/debug/$REPO_NAME-$SHORT_SHA-debug.apk && ls -la mobile/build/outputs/apk/debug/$REPO_NAME-$SHORT_SHA-debug.apk']

- name: gcr.io/cloud-builders/gsutil
  id: 'publish-artifacts'
  args: ['cp', '/persistent_volume/mobile/build/outputs/apk/debug/$REPO_NAME-$SHORT_SHA-debug.apk', 'gs://eu.artifacts.$PROJECT_ID.appspot.com/android/']
  volumes:
  - name: data
    path: /persistent_volume

timeout: 1200s
````

b) Injecting files at build-time requires IAM `roles/secretmanager.secretAccessor` for the service account.
File `keystore.properties` is useless, unless one would also inject `/root/.android/*.keystore` for code signing.
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
  waitFor: ['gcloud-secrets']
...
````

c) Cloud KMS can be used decrypt files; this requires IAM `roles/cloudkms.cryptoKeyEncrypterDecrypter` for the service account:

 ![Cloud Build - Screenshot 02](https://github.com/syslogic/cloudbuild-android/raw/master/screenshots/screenshot_02.png)

And a step which runs `gcloud kms decrypt` (there are scripts in the `/scripts` directy, for encrypting the `*.enc` files):

````
- name: 'gcr.io/cloud-builders/gcloud'
  id: 'kms-decode'
  entrypoint: 'bash'
  waitFor: ['pull-image']
  args:
    - '-c'
    - |
      mkdir -p /root/.android
      gcloud kms decrypt --ciphertext-file=credentials/keystore.properties.enc --plaintext-file=/persistent_volume/keystore.properties --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/google-services.json.enc --plaintext-file=/persistent_volume/mobile/google-services.json --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/debug.keystore.enc --plaintext-file=/root/.android/debug.keystore --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/release.keystore.enc --plaintext-file=/root/.android/release.keystore --location=global --keyring=android-gradle --key=default
      rm -v ./credentials/*.enc
  volumes:
    - name: data
      path: /persistent_volume

- name: gcr.io/cloud-builders/docker
  id: 'gradle-build'
  waitFor: ['kms-decode']
  ...

````

# Conclusion

- Firebase App Distribution is support by the Cloud Build service account, when assigning the "Firebase App Distribution Admin" role.

# Also see

 - GitHub Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) for GitHub integration.
 - GitHub [Google Cloud Build](https://github.com/GoogleCloudBuild) (official).

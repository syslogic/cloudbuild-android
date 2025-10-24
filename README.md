# Android Builder Image
<img src="https://storage.googleapis.com/cloudbuild-badges/cloudbuild-android-master.svg" alt=""/>

## Docker Image

One can meanwhile pull the ready-built image from GitHub Docker registry:

    docker pull ghcr.io/syslogic/cloudbuild-android:latest

 ---

## What it does?

- It builds a Docker container from [Google Cloud Source Repositories](https://cloud.google.com/source-repositories) or [GitHub](https://github.com/marketplace/google-cloud-build) with eg. [Google Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).
- It publishes the image to the [Container Registry](https://console.cloud.google.com/gcr/images)  as `eu.gcr.io/$PROJECT_ID/android-builder`.
- It's based upon `amazoncorretto:17-al2-jdk`, Android `sdkmanager` and Gradle.

## The dummy Android app (for testing purposes only)

- It supports publishing to Bucket & Firebase App Distribution with Cloud KMS decryption for credentials.
- Android NDK and Firebase Crashlytics NDK crash reporting can be enabled by uncommenting a few lines.

## How to use it with Cloud Build?

 - The image first needs to be built itself (!), in order to build Android applications with it.
 - Hosting the built image would be a) less customizable and b) the traffic would be charged.
 - In order to get started, import to [Cloud Source Repositories](https://source.cloud.google.com/repo/new) and set up a build [trigger](https://console.cloud.google.com/cloud-build/triggers) there.
 
  ![Cloud Build - Screenshot 01](https://raw.githubusercontent.com/syslogic/cloudbuild-android-builder/master/screenshots/screenshot_01.png)
 
 - After having built the image, a new container should show up below `eu.gcr.io/$PROJECT_ID/android-builder`.
 - This container can then be used <b>in another</b> Android project's (or another Git branch's) `cloudbuild.yaml`, in order not to build it every time.

## Cloud Build Variable Substitutions

One can pre-install SDK packages with the `sdkmanager`, when passing `_ANDROID_SDK_PACKAGES`.<br/>
And one can pre-install Gradle by passing `_GRADLE_VERSION`.<br/>
At the moment these are both statically set in [`cloudbuild.yaml`](https://github.com/syslogic/cloudbuild-android/blob/master/cloudbuild.yaml), but the code is there.

 - `_CLI_TOOLS_VERSION` ~ `13114758`
 - `_ANDROID_SDK_PACKAGES` ~ `platform-tools platforms;android-36 build-tools;36.0.0 emulator`
 - `_GRADLE_VERSION` ~ `9.1.0`

## Usage example: Google Cloud Build

These examples assume that you already have the image in your project's private container registry.

Hostname `eu.gcr.io` (also bucket name `eu.artifacts`) can be replaced with `us.gcr.io` or `gcr.io`.

a) This uploads debug APK files with `gsutil` to `gs://eu.artifacts.$PROJECT_ID.appspot.com/android/`:

````
# cloudbuild.yaml

steps:

- name: eu.gcr.io/$PROJECT_ID/cloudbuild-android
  id: 'docker-pull'
  args: ['cp', '-a', '.', '/persistent_volume']
  volumes:
  - name: data
    path: /persistent_volume

- name: gcr.io/cloud-builders/docker
  id: 'gradle-build'
  volumes:
  - name: data
    path: /persistent_volume
  args: ['run', '-v', 'data:/workspace', '--rm', 'eu.gcr.io/$PROJECT_ID/cloudbuild', '/bin/sh', '-c', 'cd /workspace && ./gradlew mobile:assembleDebug && mv mobile/build/outputs/apk/debug/mobile-debug.apk mobile/build/outputs/apk/debug/$REPO_NAME-$SHORT_SHA-debug.apk && ls -la mobile/build/outputs/apk/debug/$REPO_NAME-$SHORT_SHA-debug.apk']

- name: gcr.io/cloud-builders/gsutil
  id: 'publish-gsutil'
  args: ['cp', '/persistent_volume/mobile/build/outputs/apk/debug/$REPO_NAME-$SHORT_SHA-debug.apk', 'gs://eu.artifacts.$PROJECT_ID.appspot.com/android/']
  volumes:
  - name: data
    path: /persistent_volume

timeout: 1200s
````
b) Cloud KMS can be used to decrypt credentials; this requires IAM role `roles/cloudkms.cryptoKeyEncrypterDecrypter` for the service account:

 ![Cloud Build - Screenshot 02](https://github.com/syslogic/cloudbuild-android/raw/master/screenshots/screenshot_02.png)

The first step mounts volume `data`. The second step runs `gcloud kms decrypt` (there are scripts in the `/scripts` directory, for encrypting the [`*.enc`](https://github.com/syslogic/cloudbuild-android/tree/master/credentials) files). The Gradle task in the third step runs `mobile:assembleRelease mobile:appDistributionUploadRelease`, which uploads a signed release APK to Firebase App Distribution. This requires a separate service account with a `google-service-account.json`, because it is not possible to access the Cloud Build service account credentials.
````
# cloudbuild.yaml

steps:

- name: eu.gcr.io/$PROJECT_ID/cloudbuild-android
  id: 'docker-pull'
  args: ['cp', '-a', '.', '/persistent_volume']
  volumes:
  - name: data
    path: /persistent_volume

- name: gcr.io/cloud-builders/gcloud
  id: 'kms-decode'
  entrypoint: 'bash'
  waitFor: ['docker-pull']
  args:
    - '-c'
    - |
      mkdir -p /persistent_volume/.android
      gcloud kms decrypt --ciphertext-file=credentials/keystore.properties.enc --plaintext-file=/persistent_volume/keystore.properties --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/google-service-account.json.enc --plaintext-file=/persistent_volume/credentials/google-service-account.json --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/google-services.json.enc --plaintext-file=/persistent_volume/mobile/google-services.json --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/debug.keystore.enc --plaintext-file=/persistent_volume/.android/debug.keystore --location=global --keyring=android-gradle --key=default
      gcloud kms decrypt --ciphertext-file=credentials/release.keystore.enc --plaintext-file=/persistent_volume/.android/release.keystore --location=global --keyring=android-gradle --key=default
      rm -v ./credentials/*.enc
  volumes:
    - name: data
      path: /persistent_volume

- name: gcr.io/cloud-builders/docker
  id: 'firebase-distribution'
  waitFor: ['kms-decode']
  env:
    - 'BUILD_NUMBER=$BUILD_ID'
  volumes:
    - name: data
      path: /persistent_volume
  args: [
    'run',
    '--rm', 'eu.gcr.io/$PROJECT_ID/cloudbuild',
    '-v', 'data:/workspace',
    '/bin/sh', '-c', 'cd /workspace && gradle mobile:assembleRelease mobile:appDistributionUploadRelease'
  ]

timeout: 1200s
````
## Alternative: Cloud KMS Gradle Automation

The example app uses [Google Cloud KMS Gradle Plugin](https://github.com/syslogic/google-cloud-kms-gradle-plugin), which depends on environmental variable `_CLOUD_KMS_KEY_PATH`. It does about the same as the above step `kms-decode` does, but at build time:
````shell
./gradlew mobile:cloudKmsDecrypt mobile:assembleRelease mobile:appDistributionUploadRelease
````
## Usage example: Bitbucket Pipeline

These substitutions use no underscore.

 - `CLI_TOOLS_VERSION` ~ `13114758`
 - `ANDROID_SDK_PACKAGES` ~ `platform-tools platforms;android-36 build-tools;36.0.0 emulator`
 - `GRADLE_VERSION` ~ `9.1.0`
 - `DOCKER_IMAGE` ~  the location of the Docker image previously built.

## GCP Service Account

- for Firebase AppDistribution, the service account needs IAM role "Firebase App Distribution Admin".
- for Google Play Store, the "Google Play Android Developer API" needs to be enabled for the project.

## Also see
 - [Creating a Serverless Mobile Delivery Pipeline](https://cloud.google.com/architecture/creating-serverless-mobile-delivery-pipeline)
 - [Simplify your CI processes with GitHub and Google Cloud Build](https://github.blog/2018-07-26-simplify-your-ci-process/)
 - Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) for GitHub integration.
 - [GitHub: Google Cloud Build](https://github.com/GoogleCloudBuild) (official).
 - [Jetbrains Space: Automation (CI/CD)](https://www.jetbrains.com/help/space/automation.html).
 - [Jetbrains Space IDE plugin](https://plugins.jetbrains.com/plugin/13362-space)

# What it does?

 - It builds from [Cloud Source Repositories](https://cloud.google.com/source-repositories) with [Cloud Build](https://cloud.google.com/source-repositories/docs/integrating-with-cloud-build).

 - It publishes a Docker container as `gcr.io/$PROJECT_ID/cloudbuild/android-builder` to the [Container Registry](https://console.cloud.google.com/gcr/images).

 - GitHub Marketplace [Google Cloud Build](https://github.com/marketplace/google-cloud-build) provides GitHub integration.

# How to use it?

 - Import to [Cloud Source Repositories](https://cloud.google.com/source-repositories) and setup a build trigger there.
 - After having build it, a new container should show up below `gcr.io/$PROJECT_ID/cloudbuild/android-builder`.
 - The Docker container can then be referenced in another source repository's `Dockerfile`.

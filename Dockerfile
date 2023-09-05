# CloudBuild Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-alpine as builder
LABEL description="Android Builder" version="1.1.0" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
RUN apk add --no-cache wget unzip sed xxd

USER root
ENV CLI_TOOLS_VERSION=10406996
ENV CLI_TOOLS_ZIP_FILE=commandlinetools-linux-${CLI_TOOLS_VERSION}_latest.zip \
ENV ANDROID_HOME=/opt/android-sdk
PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/cmdline-tools/tools/bin:${PATH}"

ARG GRADLE_WRAPPER_VERSION
ARG ANDROID_SDK_PACKAGES
COPY . /workspace
WORKDIR /workspace

RUN pwd
RUN ls -la

# default pre build script
CMD ./scripts/pre_build.sh

# run ./gradlew once in order to install the Gradle wrapper
CMD ./gradlew

# fetches SDK components & dependencies as defined in the build.gradle
# this is rather optional, because `sdkmanager` is being used instead.
# RUN ./gradlew build

# default post build script
CMD ./scripts/post_build.sh

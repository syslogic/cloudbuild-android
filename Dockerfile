# CloudBuild Dockerfile for building with Android SDK
FROM openjdk:8 as builder
LABEL version="1.0.0" maintainer="Martin Zeitler" description="CloudBuild Dockerfile" repository="https://github.com/syslogic/cloudbuild-android"
ENV ANDROID_HOME /opt/android-sdk
ARG ANDROID_SDK_VERSION
ARG ANDROID_NDK_VERSION
ARG GRADLE_VERSION

COPY . /workspace
WORKDIR /workspace

# default pre build script
RUN chmod +x ./scripts/pre_build.sh && ./scripts/pre_build.sh

# start ADB server (optional; just testing while building the container)
EXPOSE 5037
# RUN ${ANDROID_HOME}/platform-tools/adb start-server

# run the Gradle wrapper once
# fetches the SDK components & dependencies as defined in the build.gradle
RUN ./gradlew build

# default post build script
RUN chmod +x ./scripts/pre_build.sh && ./scripts/post_build.sh

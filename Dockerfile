# CloudBuild Dockerfile for building with Android SDK/NDK
FROM openjdk:8 as builder
LABEL description="Cloud Build - Android SDK Builder" version="1.0.2" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
ENV ANDROID_HOME /opt/android-sdk
ARG GRADLE_VERSION
ARG SDK_PACKAGES

COPY . /workspace
WORKDIR /workspace

# ADB :5037
EXPOSE 5037

# default pre build script
RUN ./scripts/pre_build.sh

# run the Gradle wrapper once (it needs to download)
RUN ./gradlew

# fetches the SDK components & dependencies as defined in the build.gradle
# meanwhile this is optional, because the sdkmanager is being used instad.
# RUN ./gradlew build

# default post build script
RUN ./scripts/post_build.sh

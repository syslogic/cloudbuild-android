# CloudBuild Dockerfile for building with Android SDK/NDK
FROM openjdk:8 as builder
LABEL description="CloudBuild for Android SDK/NDK" version="1.0.1" maintainer="Martin Zeitler" repository="https://github.com/syslogic/cloudbuild-android"
ENV ANDROID_HOME /opt/android-sdk
ARG ANDROID_SDK_VERSION
ARG ANDROID_SDK_PLATFORM
ARG BUILD_TOOLS_VERSION
ARG ANDROID_NDK_VERSION
ARG GRADLE_VERSION

COPY . /workspace
WORKDIR /workspace

# default pre build script
RUN ./scripts/pre_build.sh

# ADB :5037
EXPOSE 5037

# run the Gradle wrapper once
# fetches the SDK components & dependencies as defined in the build.gradle
# meanwhile this is optional, because the sdkmanager is being used instad.
# RUN ./gradlew build

# default post build script
RUN ./scripts/post_build.sh

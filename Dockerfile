# CloudBuild Dockerfile for building with Android SDK/NDK
FROM openjdk:8 as builder
LABEL description="CloudBuild for Android SDK/NDK" version="1.0.1" maintainer="Martin Zeitler" repository="https://github.com/syslogic/cloudbuild-android"
ENV ANDROID_HOME /opt/android-sdk
ARG ANDROID_SDK_VERSION
ARG ANDROID_SDK_PLATFORM
ARG ANDROID_NDK_VERSION
ARG GRADLE_VERSION

COPY . /workspace
WORKDIR /workspace

# default pre build script
RUN chmod +x ./scripts/pre_build.sh && ./scripts/pre_build.sh

# ADB :5037
EXPOSE 5037

# run the Gradle wrapper once
# fetches the SDK components & dependencies as defined in the build.gradle
RUN ./gradlew build

# default post build script
RUN chmod +x ./scripts/pre_build.sh && ./scripts/post_build.sh

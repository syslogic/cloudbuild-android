# CloudBuild Dockerfile for building with Android SDK/NDK
FROM openjdk:11-jdk as builder
ENV ANDROID_HOME /opt/android-sdk
ARG GRADLE_WRAPPER_VERSION
ARG ANDROID_SDK_PACKAGES
ARG GITHUB_ACCESS_TOKEN

COPY . /workspace
WORKDIR /workspace

# ADB :5037
EXPOSE 5037

# default pre build cleanup script
RUN ./scripts/pre_cleanup.sh

# default pre build script
RUN ./scripts/pre_build.sh

# run ./gradlew once in order to install the Gradle wrapper
RUN ./gradlew

# fetches SDK components & dependencies as defined in the build.gradle
# this is rather optional, because the sdkmanager is being used instad.
# RUN ./gradlew build

# default post build script
RUN ./scripts/post_build.sh

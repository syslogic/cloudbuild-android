# CloudBuild Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-alpine-jdk as builder
LABEL description="Cloud Build - Android SDK Builder" version="1.0.8" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
ENV ANDROID_HOME /opt/android-sdk
ARG GRADLE_WRAPPER_VERSION
ARG ANDROID_SDK_PACKAGES
COPY . /workspace
WORKDIR /workspace

# ADB :5037
EXPOSE 5037

# default pre build script
RUN ./scripts/pre_build.sh

# run ./gradlew once in order to install the Gradle wrapper
RUN ./gradlew

# fetches SDK components & dependencies as defined in the build.gradle
# this is rather optional, because `sdkmanager` is being used instead.
# RUN ./gradlew build

# default post build script
RUN ./scripts/post_build.sh


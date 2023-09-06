# Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-alpine as builder
LABEL description="Android Builder" version="1.1.0" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
RUN apk add --no-cache wget unzip sed xxd
ARG GRADLE_WRAPPER_VERSION
ARG ANDROID_SDK_PACKAGES

ENV CLI_TOOLS_VERSION=10406996
ENV CLI_TOOLS_ZIP_FILE=commandlinetools-linux-${CLI_TOOLS_VERSION}_latest.zip
ENV CLI_TOOLS_URL=https://dl.google.com/android/repository/${CLI_TOOLS_ZIP_FILE}

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"

# Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
RUN wget -q "${CLI_TOOLS_URL}"
RUN unzip -qq ${CLI_TOOLS_ZIP_FILE} -d "${ANDROID_HOME}"
RUN rm ${CLI_TOOLS_ZIP_FILE}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses >/dev/null

# Installing all Android SDK Packages at once, in order to query the repository only once.
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install ${ANDROID_SDK_PACKAGES}

# default pre build script
CMD ./scripts/pre_build.sh

# run ./gradlew once in order to install the Gradle wrapper
CMD ./gradlew

# default post build script
CMD ./scripts/post_build.sh

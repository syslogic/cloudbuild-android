# Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-alpine-jdk as builder
LABEL description="Android Builder" version="1.2.0" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
RUN apk add --no-cache bash wget unzip xxd

# Arguments
ARG _CLI_TOOLS_VERSION
ARG _ANDROID_SDK_PACKAGES

# PATH
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${ANDROID_HOME}/cmdline-tools/bin:${PATH}"

# Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
ENV CLI_TOOLS_ZIP=commandlinetools-linux-${_CLI_TOOLS_VERSION}_latest.zip
ENV CLI_TOOLS_URL=https://dl.google.com/android/repository/${CLI_TOOLS_ZIP}
RUN wget -q "${CLI_TOOLS_URL}" && unzip -qq ${CLI_TOOLS_ZIP} -d "${ANDROID_HOME}" && rm ${CLI_TOOLS_ZIP}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

# Android SDK packages
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install ${_ANDROID_SDK_PACKAGES} > /dev/null

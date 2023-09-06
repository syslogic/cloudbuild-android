# Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-alpine as builder
LABEL description="Android Builder" version="1.2.0" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
RUN apk add --no-cache wget unzip xxd
WORKDIR /mnt/space/work
USER root

ARG _CLI_TOOLS_VERSION
ARG _ANDROID_SDK_PACKAGES
ARG _GRADLE_VERSION

ENV ANDROID_HOME=/opt/android-sdk
ENV GRADLE_HOME=/opt/gradle

ENV PATH="${ANDROID_HOME}/cmdline-tools/bin:${PATH}"
ENV CLI_TOOLS_ZIP=commandlinetools-linux-${_CLI_TOOLS_VERSION}_latest.zip
ENV CLI_TOOLS_URL=https://dl.google.com/android/repository/${CLI_TOOLS_ZIP}

RUN pwd
RUN ls -la

# Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
RUN wget -q "${CLI_TOOLS_URL}" && unzip -qq ${CLI_TOOLS_ZIP} -d "${ANDROID_HOME}" && rm ${CLI_TOOLS_ZIP}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

# Installing all Android SDK üackages at once, in order to query the repository only once.
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install ${_ANDROID_SDK_PACKAGES} > /dev/null

ENV GRADLE_ZIP=gradle-${_GRADLE_VERSION}-bin.zip
ENV GRADLE_URL=https://downloads.gradle.org/distributions/${GRADLE_ZIP}
RUN wget -q "${GRADLE_URL}" && unzip -qq ${GRADLE_ZIP} -d "${GRADLE_HOME}" && rm ${GRADLE_ZIP}

RUN cd "${GRADLE_HOME}" && ls -la

# run ./gradlew once in order to install the Gradle wrapper
CMD [ "gradle" ]

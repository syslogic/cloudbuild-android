# Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-alpine as builder
LABEL description="Android Builder" version="1.2.0" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
RUN apk add --no-cache wget unzip xxd
EXPOSE 5005/tcp

# Arguments
ARG _CLI_TOOLS_VERSION
ARG _ANDROID_SDK_PACKAGES
ARG _GRADLE_VERSION

# PATH
ENV ANDROID_HOME=/opt/android-sdk
ENV GRADLE_HOME=/opt/gradle-${_GRADLE_VERSION}
ENV PATH="${ANDROID_HOME}/cmdline-tools/bin:${GRADLE_HOME}/bin:${PATH}"

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

# Gradle
ENV GRADLE_ZIP=gradle-${_GRADLE_VERSION}-bin.zip
ENV GRADLE_URL=https://downloads.gradle.org/distributions/${GRADLE_ZIP}
RUN wget -q "${GRADLE_URL}" && unzip -qq ${GRADLE_ZIP} -d "/opt" && rm ${GRADLE_ZIP}

# Gradle User Home
RUN mkdir -p ~/.gradle

# Idle Timeout
RUN echo "org.gradle.daemon.idletimeout=60000" >> ~/.gradle/gradle.properties

# Welcome message
RUN echo "systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false" > ~/.gradle/gradle.properties
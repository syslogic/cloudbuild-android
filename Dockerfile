# Dockerfile for building with Android SDK/NDK, including Google Cloud SDK.
FROM amazoncorretto:17-al2-jdk as builder
LABEL description="Android Builder" version="1.2.2" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"

# Packages
RUN yum -y install wget unzip xxd libidn && yum -y upgrade
# ADD credentials/google_cloud.repo /etc/yum.repos.d
# RUN yum -y install deltarpm google-cloud-sdk wget unzip xxd libidn && yum -y upgrade

# Arguments, now with default values.
ARG _CLI_TOOLS_VERSION=12700392
ARG _ANDROID_SDK_PACKAGES="platform-tools platforms;android-35 build-tools;35.0.0"
ARG _GRADLE_VERSION=8.12

# Path
ENV ANDROID_HOME=/opt/android-sdk
ENV GRADLE_HOME=/opt/gradle-${_GRADLE_VERSION}
# ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${GRADLE_HOME}/bin:${PATH}"
ENV PATH="${ANDROID_HOME}/cmdline-tools/bin:${GRADLE_HOME}/bin:${PATH}"

# Gradle
ENV GRADLE_ZIP=gradle-${_GRADLE_VERSION}-bin.zip
ENV GRADLE_URL=https://downloads.gradle.org/distributions/${GRADLE_ZIP}
RUN wget -q ${GRADLE_URL} && unzip -qq ${GRADLE_ZIP} -d /opt && rm ${GRADLE_ZIP}

# Android command-line tools (has sdkmanager)
# The default location would be: "${ANDROID_HOME}/cmdline-tools/latest".
# https://developer.android.com/studio#command-tools
ENV CLI_TOOLS_ZIP=commandlinetools-linux-${_CLI_TOOLS_VERSION}_latest.zip
ENV CLI_TOOLS_URL=https://dl.google.com/android/repository/${CLI_TOOLS_ZIP}
RUN wget -q "${CLI_TOOLS_URL}" && unzip -qq ${CLI_TOOLS_ZIP} -d "${ANDROID_HOME}" && rm ${CLI_TOOLS_ZIP}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses > /dev/null

# Android SDK packages
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install ${_ANDROID_SDK_PACKAGES} > /dev/null

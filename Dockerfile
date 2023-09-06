# Dockerfile for building with Android SDK/NDK
FROM amazoncorretto:17-al2-jdk as builder
LABEL description="Android Builder" version="1.2.0" repository="https://github.com/syslogic/cloudbuild-android" maintainer="Martin Zeitler"
RUN ["/bin/bash", "-c", "./scripts/google_cloud_sdk.sh"]
RUN yum -y install wget unzip xxd libidn

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

# Gradle
ENV GRADLE_ZIP=gradle-${_GRADLE_VERSION}-bin.zip
ENV GRADLE_URL=https://downloads.gradle.org/distributions/${GRADLE_ZIP}
RUN wget -q ${GRADLE_URL} && unzip -qq ${GRADLE_ZIP} -d /opt && rm ${GRADLE_ZIP}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses > /dev/null

# Android SDK packages
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install ${_ANDROID_SDK_PACKAGES} > /dev/null

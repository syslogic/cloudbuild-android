# CloudBuild Dockerfile for building with Android SDK
FROM openjdk:8 as builder
LABEL maintainer="Martin Zeitler <martin@syslogic.io>"
COPY . /workspace
WORKDIR /workspace

# default pre build script
RUN chmod +x ./scripts/pre_cloudbuild.sh && ./scripts/pre_cloudbuild.sh

# install Android command-line tools and accept licenses
# https://developer.android.com/studio#command-tools
ARG ANDROID_SDK_VERSION=6200805
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && unzip -qq *tools*linux*.zip -d ${ANDROID_HOME} && rm *tools*linux*.zip
RUN chmod +x ./scripts/license_accepter.sh && ./scripts/license_accepter.sh $ANDROID_HOME

# install Android platform tools
RUN wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip && unzip -qq platform-tools-latest-linux.zip -d ${ANDROID_HOME} && rm platform-tools-latest-linux.zip

# start ADB server (optional; just testing while building the container)
EXPOSE 5037
RUN ${ANDROID_HOME}/platform-tools/adb start-server

# run the Gradle wrapper (optional; just testing while building the container)
RUN ./gradlew build

# default post build script
RUN chmod +x ./scripts/pre_cloudbuild.sh && ./scripts/post_cloudbuild.sh


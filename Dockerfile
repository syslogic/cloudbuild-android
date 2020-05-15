# CloudBuild Dockerfile for building with Android SDK
FROM openjdk:8 as builder
ENV ANDROID_HOME /opt/android-sdk
ARG ANDROID_SDK_VERSION
COPY . /workspace
WORKDIR /workspace

# default pre build script
RUN chmod +x ./scripts/pre_cloudbuild.sh && ./scripts/pre_cloudbuild.sh

# install Android command-line tools
# https://developer.android.com/studio#command-tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && unzip -qq *tools*linux*.zip -d ${ANDROID_HOME} && rm *tools*linux*.zip

# install Android platform tools
# https://developer.android.com/studio/releases/platform-tools
RUN wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip && unzip -qq platform-tools-latest-linux.zip -d ${ANDROID_HOME} && rm platform-tools-latest-linux.zip

# accept Android SDK licenses
RUN chmod +x ./scripts/license_accepter.sh && ./scripts/license_accepter.sh ${ANDROID_HOME}

# start ADB server (optional; just testing while building the container)
EXPOSE 5037
# RUN ${ANDROID_HOME}/platform-tools/adb start-server

# run the Gradle wrapper once
# fetches the SDK components & dependencies as defined in the build.gradle
RUN ./gradlew build

# default post build script
RUN chmod +x ./scripts/pre_cloudbuild.sh && ./scripts/post_cloudbuild.sh

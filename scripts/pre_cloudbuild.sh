#!/bin/bash
# uses https://developer.android.com/studio/command-line/sdkmanager.html
# written 2020 by Martin Zeitler

# install Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
if [ "x$ANDROID_SDK_VERSION" = "x" ] ; then
    echo _ANDROID_SDK_VERSION not provided, skipping install. ;
else
    CLI_TOOLS_ZIPFILE=commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
    wget -q https://dl.google.com/android/repository/${CLI_TOOLS_ZIPFILE}
    unzip -qq ${CLI_TOOLS_ZIPFILE} -d ${ANDROID_HOME}
    rm ${CLI_TOOLS_ZIPFILE}
fi

# accept licenses
yes | ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses >/dev/null

# install Android platform tools (with sdkmanager)
#${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --list
${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools"

# install Android NDK (with sdkmanager)
if [ "x$ANDROID_NDK_VERSION" = "x" ] ; then
    echo _ANDROID_NDK_VERSION not provided, skipping install. ;
else
    ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "ndk;${ANDROID_NDK_VERSION}"
fi

# change Gradle wrapper version; eg. from version 5.6.4 to 6.4.1
if [ "x$GRADLE_VERSION" = "x" ] ; then
    echo _GRADLE_VERSION not provided, using the default version. ;
else
    WRAPPER_PROPERTIES=/workspace/gradle/wrapper/gradle-wrapper.properties
    sed -i -e "s/5\.6\.4/${GRADLE_VERSION}/g" ${WRAPPER_PROPERTIES}
fi

# cleanup build directory
rm -R /workspace/.github
rm -R /workspace/credentials
rm -R /workspace/screenshots
rm /workspace/.gitignore
rm /workspace/cloudbuild.yaml
rm /workspace/Dockerfile
rm /workspace/README.md
rm /workspace/LICENSE

chmod +x ./gradlew
ls -la

#!/bin/bash
# pre-build; written 2020 by Martin Zeitler

# Cleanup build directory
rm -R /workspace/.github
rm -R /workspace/credentials
rm -R /workspace/screenshots
rm /workspace/.gitignore
rm /workspace/cloudbuild.yaml
rm /workspace/Dockerfile
rm /workspace/README.md
rm /workspace/LICENSE
echo "Build Directory Listing:"
ls -la

# Install Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
# https://developer.android.com/studio/command-line/sdkmanager.html
if [ "x$ANDROID_SDK_VERSION" = "x" ] ; then
    ANDROID_SDK_VERSION=6200805 ;
fi
CLI_TOOLS_ZIPFILE=commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
wget -q https://dl.google.com/android/repository/${CLI_TOOLS_ZIPFILE}
unzip -qq ${CLI_TOOLS_ZIPFILE} -d ${ANDROID_HOME}
rm ${CLI_TOOLS_ZIPFILE}

# Android SDK licenses
yes | ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses >/dev/null

# List Packages
#${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --list

# Android Platform Tools (always install)
PACKAGES="platform-tools"

# Android SDK Platform
if [ "x$ANDROID_SDK_PLATFORM" = "x" ] ; then
    echo _ANDROID_SDK_PLATFORM not provided, skipping install. ;
else
    PACKAGES="${PACKAGES} platforms;android-${ANDROID_SDK_PLATFORM}"
fi

# Android SDK Build-Tools
if [ "x$BUILD_TOOLS_VERSION" = "x" ] ; then
    echo _BUILD_TOOLS_VERSION not provided, skipping install. ;
else
    PACKAGES="${PACKAGES} build-tools;${BUILD_TOOLS_VERSION}"
fi

# Android NDK
if [ "x$ANDROID_NDK_VERSION" = "x" ] ; then
    echo _ANDROID_NDK_VERSION not provided, skipping install. ;
else
    PACKAGES="${PACKAGES} ndk;${ANDROID_NDK_VERSION}"
fi

# Installing all packages at once, in order to query the repository only once
echo "${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install ${PACKAGES}"
${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install $PACKAGES

# change Gradle wrapper version; eg. from version 5.6.4 to 6.4.1
if [ "x$GRADLE_VERSION" = "x" ] ; then
    echo _GRADLE_VERSION not provided, using the default version. ;
else
    if [ "$GRADLE_VERSION" != "5.6.4" ] ; then
        WRAPPER_PROPERTIES=/workspace/gradle/wrapper/gradle-wrapper.properties
        sed -i -e "s/5\.6\.4/${GRADLE_VERSION}/g" ${WRAPPER_PROPERTIES}
    fi
fi

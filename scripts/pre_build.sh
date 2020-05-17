#!/bin/bash
# pre-build; written 2020 by Martin Zeitler
CLI_TOOLS_VERSION=6200805
CLI_TOOLS_ZIPFILE=commandlinetools-linux-${CLI_TOOLS_VERSION}_latest.zip

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
wget -q https://dl.google.com/android/repository/${CLI_TOOLS_ZIPFILE}
unzip -qq ${CLI_TOOLS_ZIPFILE} -d ${ANDROID_HOME}
rm ${CLI_TOOLS_ZIPFILE}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
yes | ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses >/dev/null

# List Packages
#${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --list

# Android Platform Tools (always install)
PACKAGES="platform-tools"

# Android SDK Packages
if [ "x$SDK_PACKAGES" = "x" ] ; then
    echo _SDK_PACKAGES not provided by build trigger, installing ${PACKAGES}.
else
    PACKAGES=$SDK_PACKAGES
fi

# Installing all packages at once, in order to query the repository only once
echo "${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install ${PACKAGES}"
${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install $PACKAGES

# change Gradle wrapper version; eg. from version 5.6.4 to 6.4.1
if [ "x$GRADLE_VERSION" = "x" ] ; then
    echo _GRADLE_VERSION not provided by build trigger, using the default version. ;
else
    if [ "$GRADLE_VERSION" != "5.6.4" ] ; then
        WRAPPER_PROPERTIES=/workspace/gradle/wrapper/gradle-wrapper.properties
        sed -i -e "s/5\.6\.4/${GRADLE_VERSION}/g" ${WRAPPER_PROPERTIES}
    fi
fi

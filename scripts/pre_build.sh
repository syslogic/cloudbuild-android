#!/bin/bash
# pre-build; written 2020 by Martin Zeitler
CLI_TOOLS_VERSION=6514223
CLI_TOOLS_ZIPFILE=commandlinetools-linux-${CLI_TOOLS_VERSION}_latest.zip

# A) Android command-line tools (has sdkmanager)
# https://developer.android.com/studio#command-tools
wget -q https://dl.google.com/android/repository/${CLI_TOOLS_ZIPFILE}
unzip -qq ${CLI_TOOLS_ZIPFILE} -d ${ANDROID_HOME}
rm ${CLI_TOOLS_ZIPFILE}

# Android SDK licenses
# https://developer.android.com/studio/command-line/sdkmanager.html
yes | ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses >/dev/null

# Android Platform Tools
PACKAGES="platform-tools"

# Cloud Build trigger substitution ${_ANDROID_SDK_PACKAGES}
if [ "x$ANDROID_SDK_PACKAGES" = "x" ] ; then
    echo _ANDROID_SDK_PACKAGES not provided by build trigger, installing ${PACKAGES}.
else
    PACKAGES=$ANDROID_SDK_PACKAGES
fi

# Installing all Android SDK Packages at once, in order to query the repository only once.
echo "${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install ${PACKAGES}"
${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --install $PACKAGES


# B) Change the version in gradle-wrapper.properties; eg. from version 5.6.4 to 6.4.1
# Cloud Build trigger substitution ${_GRADLE_WRAPPER_VERSION}
if [ "x$GRADLE_WRAPPER_VERSION" = "x" ] ; then
    echo _GRADLE_WRAPPER_VERSION not provided by build trigger, using the default version. ;
else
    if [ "$GRADLE_WRAPPER_VERSION" != "5.6.4" ] ; then
        WRAPPER_PROPERTIES=/workspace/gradle/wrapper/gradle-wrapper.properties
        sed -i -e "s/5\.6\.4/${GRADLE_WRAPPER_VERSION}/g" ${WRAPPER_PROPERTIES}
    fi
fi

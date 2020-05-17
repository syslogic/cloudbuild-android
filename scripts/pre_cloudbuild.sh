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
${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --list

# update command line tools
${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "cmdline-tools;latest"
#${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "platforms;android-29"
ls -la ${ANDROID_HOME}

# install Android platform tools
PLATFORM_TOOLS_ZIPFILE=platform-tools-latest-linux.zip
wget -q https://dl.google.com/android/repository/${PLATFORM_TOOLS_ZIPFILE}
unzip -qq ${PLATFORM_TOOLS_ZIPFILE} -d ${ANDROID_HOME}
rm ${PLATFORM_TOOLS_ZIPFILE}

# install Android NDK
if [ "x$ANDROID_NDK_VERSION" = "x" ] ; then
    echo _ANDROID_NDK_VERSION not provided, skipping install. ;
else
    ANDROID_NDK_ZIPFILE=android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
    wget -q https://dl.google.com/android/repository/${ANDROID_NDK_ZIPFILE}
    unzip -qq ${ANDROID_NDK_ZIPFILE} -d ${ANDROID_HOME}
    rm ${ANDROID_NDK_ZIPFILE}

    # TODO: better install Android NDK using SDK Manager
    # https://developer.android.com/studio/command-line/sdkmanager.html
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

#!/bin/sh
# pre-build; written 2020-2023 by Martin Zeitler
# https://developer.android.com/studio#command-tools

# Change the version in gradle-wrapper.properties
# Cloud Build trigger substitution ${_GRADLE_WRAPPER_VERSION}
if [ "x$GRADLE_WRAPPER_VERSION" = "x" ] ; then
    echo _GRADLE_WRAPPER_VERSION not provided by build trigger, using the default version. ;
else
    if [ "$GRADLE_WRAPPER_VERSION" != "8.2" ] ; then
        WRAPPER_PROPERTIES=/workspace/gradle/wrapper/gradle-wrapper.properties
        sed -i -e "s/8\.2/${GRADLE_WRAPPER_VERSION}/g" ${WRAPPER_PROPERTIES}
    fi
fi

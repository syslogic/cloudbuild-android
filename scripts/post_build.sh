#!/bin/bash
# post-build; written 2020-2023 by Martin Zeitler

# Removing the Android application from the container
shopt -s dotglob
rm -r /workspace/*

# This directory only exists when having built with ./gradlew build
if [ -d /root/.gradle/caches ]; then
    rm -r /root/.gradle/caches/*
fi

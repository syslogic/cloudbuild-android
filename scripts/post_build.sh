#!/bin/bash
# post-build; written 2020 by Martin Zeitler

shopt -s dotglob
rm -r /workspace/*
if [ -d "/root/.gradle/caches" ]; then
    rm -r /root/.gradle/caches/*
fi

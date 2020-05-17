#!/bin/bash
# post-build; written 2020 by Martin Zeitler

shopt -s dotglob
rm -r /workspace/*

# this directory only exists when having built
if [ -d /root/.gradle/caches ]; then
    rm -r /root/.gradle/caches/*
fi

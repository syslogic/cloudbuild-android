#!/bin/bash
# post-build; written 2020 by Martin Zeitler

shopt -s dotglob
rm -r /root/.gradle/caches/*
rm -r /workspace/*

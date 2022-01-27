#!/bin/bash
# pre-cleanup; written 2020-2022 by Martin Zeitler

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


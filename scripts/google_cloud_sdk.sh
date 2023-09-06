#!/bin/bash
# https://cloud.google.com/sdk/downloads#yum
tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null <<EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
yum -y install google-cloud-sdk
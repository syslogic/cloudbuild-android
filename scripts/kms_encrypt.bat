@echo off
gcloud kms encrypt --plaintext-file=../keystore.properties --ciphertext-file=../credentials/keystore.properties.enc --location=global --keyring=android-gradle --key=default
gcloud kms encrypt --plaintext-file=../mobile/google-services.json --ciphertext-file=../credentials/google-services.json.enc --location=global --keyring=android-gradle --key=default
gcloud kms encrypt --plaintext-file=%USERPROFILE%/.android/debug.keystore --ciphertext-file=../credentials/debug.keystore.enc --location=global --keyring=android-gradle --key=default
gcloud kms encrypt --plaintext-file=%USERPROFILE%/.android/release.keystore --ciphertext-file=../credentials/release.keystore.enc --location=global --keyring=android-gradle --key=default

#!/usr/bin/env bash
# Source with protected GitLab variables. Never print or archive these files.
set -euo pipefail
: "${ANDROID_KEYSTORE_BASE64:?Set protected masked variable ANDROID_KEYSTORE_BASE64}"
: "${ANDROID_KEY_PROPERTIES_FILE:?Set protected file variable ANDROID_KEY_PROPERTIES_FILE}"
[[ -f "$ANDROID_KEY_PROPERTIES_FILE" ]]
umask 077
ANDROID_SIGNING_TEMP="$(mktemp -d)"
trap 'rm -rf "$ANDROID_SIGNING_TEMP"; rm -f android/key.properties' EXIT
printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64 --decode > "$ANDROID_SIGNING_TEMP/upload.jks"
mkdir -p android
cp "$ANDROID_KEY_PROPERTIES_FILE" android/key.properties
# Keep this absolute for reproducible clean-clone APK builds.
sed -i '/^storeFile=/d' android/key.properties
printf '\nstoreFile=%s\n' "$ANDROID_SIGNING_TEMP/upload.jks" >> android/key.properties

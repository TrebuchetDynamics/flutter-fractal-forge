#!/usr/bin/env bash
set -euo pipefail
source scripts/ci/identity.sh
export FLUTTER_BIN="$(command -v flutter)"
flutter pub get --enforce-lockfile
case "${1:?job required}" in
  android)
    source scripts/ci/android-signing.sh
    scripts/release.sh android-build --prepare="$RELEASE_VERSION" --build-number="$RELEASE_BUILD_NUMBER"
    ;;
  device)
    source scripts/ci/android-signing.sh
    scripts/pre-release-gate.sh --build-name="$RELEASE_VERSION" --build-number="$RELEASE_BUILD_NUMBER" \
      --log-dir release-artifacts/final-device-gate --skip-host
    ;;
  linux)
    scripts/release.sh linux --prepare="$RELEASE_VERSION" --build-number="$RELEASE_BUILD_NUMBER"
    ;;
  fdroid)
    tools_dir="$(find "${ANDROID_HOME:?}/build-tools" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n1)"
    export PATH="$tools_dir:$PATH"
    scripts/build-fdroid.sh --flutter-bin="$FLUTTER_BIN" --version="$RELEASE_VERSION" \
      --build-number="$RELEASE_BUILD_NUMBER" --commit="$RELEASE_COMMIT" \
      --output-dir=release-artifacts/fdroid --reproducible
    archive="release-artifacts/fractal-forge-fdroid-v$RELEASE_VERSION.tar.gz"
    tar -czf "$archive" -C release-artifacts fdroid
    ;;
  web)
    scripts/build-web-preview.sh / --build-name="$RELEASE_VERSION" --build-number="$RELEASE_BUILD_NUMBER" \
      --dart-define="RELEASE_VERSION=$RELEASE_VERSION" --dart-define="RELEASE_BUILD_NUMBER=$RELEASE_BUILD_NUMBER" \
      --dart-define="RELEASE_COMMIT=$RELEASE_COMMIT"
    mkdir -p release-artifacts
    archive="release-artifacts/fractal-forge-web-v$RELEASE_VERSION.tar.gz"
    tar -czf "$archive" -C build/web .
    ;;
  *) exit 1 ;;
esac
if [[ -n "${archive:-}" ]]; then
  printf 'version=%s\nbuild_number=%s\ncommit=%s\nsha256=%s\n' \
    "$RELEASE_VERSION" "$RELEASE_BUILD_NUMBER" "$RELEASE_COMMIT" \
    "$(sha256sum "$archive" | cut -d' ' -f1)" > "$archive.provenance"
fi

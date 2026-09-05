#!/usr/bin/env bash
set -euo pipefail
source scripts/ci/identity.sh
platform="${1:?platform required}"
version="$(cat fdroid/flutter.version)"
# Hosted Windows includes Git Bash; macOS includes bash, git, Xcode and CocoaPods.
if [[ ! -d .ci-flutter ]]; then
  git clone --depth 1 --branch "$version" https://github.com/flutter/flutter.git .ci-flutter
fi
export PATH="$PWD/.ci-flutter/bin:$PATH"
flutter --version
flutter pub get --enforce-lockfile
args=("$platform" --release --build-name="$RELEASE_VERSION" --build-number="$RELEASE_BUILD_NUMBER"
  --dart-define="RELEASE_VERSION=$RELEASE_VERSION" --dart-define="RELEASE_BUILD_NUMBER=$RELEASE_BUILD_NUMBER"
  --dart-define="RELEASE_COMMIT=$RELEASE_COMMIT")
if [[ "$platform" == ios ]]; then args+=(--no-codesign); fi
flutter build "${args[@]}"
mkdir -p release-artifacts
case "$platform" in
  windows)
    bundle="$(find build/windows -type d -path '*/runner/Release' -print -quit)"
    [[ -n "$bundle" ]] || exit 1
    archive="$PWD/release-artifacts/fractal-forge-windows-x64.zip"
    (cd "$bundle/.." && 7z a -tzip "$archive" Release)
    ;;
  macos|ios)
    if [[ "$platform" == ios ]]; then app=build/ios/iphoneos/Runner.app
    else app="$(find build/macos/Build/Products/Release -maxdepth 1 -name '*.app' -print -quit)"; fi
    [[ -n "$app" && -d "$app" ]] || exit 1
    archive="$PWD/release-artifacts/fractal-forge-$platform-unsigned.zip"
    ditto -c -k --keepParent "$app" "$archive"
    ;;
  *) echo 'Unsupported native platform' >&2; exit 1 ;;
esac
if command -v sha256sum >/dev/null; then checksum="$(sha256sum "$archive" | cut -d' ' -f1)"
else checksum="$(shasum -a 256 "$archive" | cut -d' ' -f1)"; fi
printf 'version=%s\nbuild_number=%s\ncommit=%s\nsha256=%s\n' \
  "$RELEASE_VERSION" "$RELEASE_BUILD_NUMBER" "$RELEASE_COMMIT" "$checksum" > "$archive.provenance"

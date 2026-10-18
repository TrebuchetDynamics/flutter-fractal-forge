#!/usr/bin/env bash
set -euo pipefail
platform="${1:?platform required}"
if [[ "${RELEASE_LOCAL_STAGE:-}" == 1 ]]; then
  [[ "${RELEASE_COMMIT:-}" == "$(git rev-parse HEAD)" &&
     "${RELEASE_VERSION:-}" =~ ^[0-9]+\.[0-9]+\.[1-9][0-9]*$ &&
     "${RELEASE_BUILD_NUMBER:-}" == "${RELEASE_VERSION##*.}" ]] || {
    echo 'Local release identity mismatch' >&2; exit 1;
  }
else
  source scripts/ci/identity.sh
fi
version="$(cat fdroid/flutter.version)"
ARTIFACT_DIR="${RELEASE_ARTIFACT_DIR:-release-artifacts}"
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
mkdir -p "$ARTIFACT_DIR"
case "$platform" in
  windows)
    bundle="$(find build/windows -type d -path '*/runner/Release' -print -quit)"
    [[ -n "$bundle" ]] || exit 1
    archive="$PWD/$ARTIFACT_DIR/fractal-forge-windows-x64.zip"
    (cd "$bundle/.." && 7z a -tzip "$archive" Release)
    ;;
  macos|ios)
    if [[ "$platform" == ios ]]; then app=build/ios/iphoneos/Runner.app
    else app="$(find build/macos/Build/Products/Release -maxdepth 1 -name '*.app' -print -quit)"; fi
    [[ -n "$app" && -d "$app" ]] || exit 1
    archive="$PWD/$ARTIFACT_DIR/fractal-forge-$platform-unsigned.zip"
    ditto -c -k --keepParent "$app" "$archive"
    ;;
  *) echo 'Unsupported native platform' >&2; exit 1 ;;
esac
if command -v sha256sum >/dev/null; then checksum="$(sha256sum "$archive" | cut -d' ' -f1)"
else checksum="$(shasum -a 256 "$archive" | cut -d' ' -f1)"; fi
printf 'version=%s\nbuild_number=%s\ncommit=%s\nsha256=%s\n' \
  "$RELEASE_VERSION" "$RELEASE_BUILD_NUMBER" "$RELEASE_COMMIT" "$checksum" > "$archive.provenance"

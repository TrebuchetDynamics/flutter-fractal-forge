#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_ID="com.trebuchetdynamics.fractal.forge"
FLUTTER_VERSION="3.44.6"
VERSION=""
BUILD_NUMBER=""
COMMIT=""
OUTPUT_DIR="$PROJECT_ROOT/release-artifacts/fdroid"
METADATA_ONLY=0

usage() {
  cat <<'EOF'
Usage: scripts/build-fdroid.sh --version=X.Y.Z --build-number=N --commit=SHA [options]

Build and verify the unsigned APK that the official F-Droid buildserver will
produce, then create a ready-to-submit fdroiddata metadata bundle.

Options:
  --metadata-only      Render and package fdroiddata metadata without building.
  --output-dir=PATH    Output directory (default: release-artifacts/fdroid).
  --flutter-bin=PATH   Flutter executable (default: FLUTTER_BIN or flutter).
  --reproducible       Build twice from clean output and require identical APKs.
  --help               Show this help.
EOF
}

REPRODUCIBLE=0
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
for arg in "$@"; do
  case "$arg" in
    --version=*) VERSION="${arg#--version=}" ;;
    --build-number=*) BUILD_NUMBER="${arg#--build-number=}" ;;
    --commit=*) COMMIT="${arg#--commit=}" ;;
    --output-dir=*) OUTPUT_DIR="${arg#--output-dir=}" ;;
    --flutter-bin=*) FLUTTER_BIN="${arg#--flutter-bin=}" ;;
    --metadata-only) METADATA_ONLY=1 ;;
    --reproducible) REPRODUCIBLE=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "[fdroid] ERROR: unknown argument: $arg" >&2; exit 1 ;;
  esac
done

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "[fdroid] ERROR: --version must be X.Y.Z" >&2; exit 1;
}
[[ "$BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]] || {
  echo "[fdroid] ERROR: --build-number must be a positive integer" >&2; exit 1;
}
[[ "$COMMIT" =~ ^[0-9a-f]{40}$ ]] || {
  echo "[fdroid] ERROR: --commit must be a full 40-character lowercase SHA" >&2; exit 1;
}

git -C "$PROJECT_ROOT" cat-file -e "$COMMIT^{commit}" 2>/dev/null || {
  echo "[fdroid] ERROR: release commit is not present locally: $COMMIT" >&2; exit 1;
}

VERSION_MARKER="$PROJECT_ROOT/fdroid/version.properties"
[[ -f "$VERSION_MARKER" ]] || {
  echo "[fdroid] ERROR: missing fdroid/version.properties" >&2; exit 1;
}
marker_version="$(awk -F= '$1 == "versionName" { print $2; exit }' "$VERSION_MARKER")"
marker_build="$(awk -F= '$1 == "versionCode" { print $2; exit }' "$VERSION_MARKER")"
[[ "$marker_version" == "$VERSION" && "$marker_build" == "$BUILD_NUMBER" ]] || {
  echo "[fdroid] ERROR: fdroid/version.properties does not match $VERSION+$BUILD_NUMBER" >&2
  exit 1
}

FASTLANE_SOURCE="$PROJECT_ROOT/fastlane/metadata/android/en-US"
for required in title.txt short_description.txt full_description.txt "changelogs/$BUILD_NUMBER.txt"; do
  [[ -s "$FASTLANE_SOURCE/$required" ]] || {
    echo "[fdroid] ERROR: missing F-Droid Fastlane metadata: $required" >&2; exit 1;
  }
done
short_description="$(tr -d '\r\n' < "$FASTLANE_SOURCE/short_description.txt")"
(( ${#short_description} <= 80 )) || {
  echo "[fdroid] ERROR: F-Droid short description exceeds 80 characters" >&2; exit 1;
}
[[ "$short_description" != *. ]] || {
  echo "[fdroid] ERROR: F-Droid short description must not end in a period" >&2; exit 1;
}
changelog="$(cat "$FASTLANE_SOURCE/changelogs/$BUILD_NUMBER.txt")"
(( ${#changelog} <= 500 )) || {
  echo "[fdroid] ERROR: F-Droid changelog exceeds 500 characters" >&2; exit 1;
}

OUTPUT_DIR="$(mkdir -p "$OUTPUT_DIR" && cd "$OUTPUT_DIR" && pwd -P)"
FDROIDDATA_DIR="$OUTPUT_DIR/fdroiddata"
METADATA_DIR="$FDROIDDATA_DIR/metadata"
rm -rf "$FDROIDDATA_DIR"
mkdir -p "$METADATA_DIR"

cat >"$METADATA_DIR/$PACKAGE_ID.yml" <<EOF
Categories:
  - Graphics
  - Multimedia
License: Apache-2.0
AuthorName: Trebuchet Dynamics
AutoName: Fractal Forge
WebSite: https://fractal.trebuchetdynamics.com
SourceCode: https://github.com/TrebuchetDynamics/flutter-fractal-forge
IssueTracker: https://github.com/TrebuchetDynamics/flutter-fractal-forge/issues
Changelog: https://github.com/TrebuchetDynamics/flutter-fractal-forge/blob/main/CHANGELOG.md

RepoType: git
Repo: https://github.com/TrebuchetDynamics/flutter-fractal-forge.git

MaintainerNotes: |-
  FDROID_BUILD disables the upstream signing configuration; F-Droid signs the
  resulting universal APK. Flutter's official Android embedding retains unused
  Play Store deferred-component type references even though this app declares
  no deferred components and its releaseRuntimeClasspath contains no Play Core
  dependency.

Builds:
  - versionName: $VERSION
    versionCode: $BUILD_NUMBER
    commit: $COMMIT
    output: build/app/outputs/flutter-apk/app-release.apk
    timeout: 3600
    ndk: r28b
    srclibs:
      - flutter@$FLUTTER_VERSION
    rm:
      - integration_test
      - ios
      - linux
      - macos
      - test
      - web
      - windows
      - node_modules
      - opensource
      - research
    prebuild:
      - export PUB_CACHE=\"\$(pwd)/.pub-cache\"
      - \$\$flutter\$\$/bin/flutter config --no-analytics
      - \$\$flutter\$\$/bin/flutter pub get --enforce-lockfile
    scandelete:
      - .pub-cache
    build:
      - export PUB_CACHE=\"\$(pwd)/.pub-cache\"
      - export FDROID_BUILD=1
      - version_name=\$(sed -n 's/^versionName=//p' fdroid/version.properties)
      - version_code=\$(sed -n 's/^versionCode=//p' fdroid/version.properties)
      - \$\$flutter\$\$/bin/flutter build apk --release --build-name=\"\$version_name\" --build-number=\"\$version_code\"

AutoUpdateMode: Version
UpdateCheckMode: Tags ^v[0-9]+\\.[0-9]+\\.[0-9]+$
UpdateCheckData: fdroid/version.properties|versionCode=(\\d+)|.|versionName=(.+)
CurrentVersion: $VERSION
CurrentVersionCode: $BUILD_NUMBER
EOF

source_epoch="$(git -C "$PROJECT_ROOT" show -s --format=%ct "$COMMIT")"
archive="$OUTPUT_DIR/fractal-forge-fdroiddata-v$VERSION.tar.gz"
rm -f "$archive"
TZ=UTC tar --sort=name --mtime="@$source_epoch" --owner=0 --group=0 --numeric-owner \
  -C "$OUTPUT_DIR" -cf - fdroiddata | gzip -n >"$archive"
sha256sum "$archive" >"$archive.sha256"

if (( METADATA_ONLY == 1 )); then
  echo "[fdroid] metadata bundle: $archive"
  exit 0
fi

[[ "$(git -C "$PROJECT_ROOT" rev-parse HEAD)" == "$COMMIT" ]] || {
  echo "[fdroid] ERROR: checked-out commit does not match release commit $COMMIT" >&2
  exit 1
}
command -v "$FLUTTER_BIN" >/dev/null 2>&1 || {
  echo "[fdroid] ERROR: Flutter executable not found: $FLUTTER_BIN" >&2; exit 1;
}
"$FLUTTER_BIN" --version | head -n1 | grep -Fq "Flutter $FLUTTER_VERSION" || {
  echo "[fdroid] ERROR: official recipe requires Flutter $FLUTTER_VERSION" >&2; exit 1;
}

build_apk() {
  local clean_output="${1:-0}"
  if (( clean_output == 1 )); then
    rm -rf "$PROJECT_ROOT/build"
  else
    rm -f "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk" \
      "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release-unsigned.apk"
  fi
  (
    cd "$PROJECT_ROOT"
    env SOURCE_DATE_EPOCH="$source_epoch" FDROID_BUILD=1 \
      "$FLUTTER_BIN" build apk --release \
        --build-name="$VERSION" --build-number="$BUILD_NUMBER"
  )
}

(
  cd "$PROJECT_ROOT"
  "$FLUTTER_BIN" pub get --enforce-lockfile
)
build_apk "$REPRODUCIBLE"
built_apk="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
if [[ ! -f "$built_apk" ]]; then
  built_apk="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release-unsigned.apk"
fi
[[ -f "$built_apk" ]] || {
  echo "[fdroid] ERROR: Flutter did not produce a release APK" >&2; exit 1;
}
"$SCRIPT_DIR/verify-fdroid-apk.sh" "$built_apk" "$VERSION" "$BUILD_NUMBER"

if (( REPRODUCIBLE == 1 )); then
  first_apk="$OUTPUT_DIR/.first-fdroid-build.apk"
  cp "$built_apk" "$first_apk"
  build_apk 1
  built_apk="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
  if [[ ! -f "$built_apk" ]]; then
    built_apk="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release-unsigned.apk"
  fi
  "$SCRIPT_DIR/verify-fdroid-apk.sh" "$built_apk" "$VERSION" "$BUILD_NUMBER"
  if ! cmp -s "$first_apk" "$built_apk"; then
    echo "[fdroid] ERROR: clean F-Droid builds are not byte-for-byte reproducible" >&2
    sha256sum "$first_apk" "$built_apk" >&2
    rm -f "$first_apk"
    exit 1
  fi
  rm -f "$first_apk"
  echo "[fdroid] reproducibility check passed"
fi

staged_apk="$OUTPUT_DIR/fractal-forge-fdroid-v$VERSION-unsigned.apk"
cp "$built_apk" "$staged_apk"
sha256="$(sha256sum "$staged_apk" | awk '{ print $1 }')"
cat >"$staged_apk.provenance" <<EOF
version=$VERSION
build_number=$BUILD_NUMBER
commit=$COMMIT
sha256=$sha256
unsigned=true
flutter_version=$FLUTTER_VERSION
source_date_epoch=$source_epoch
EOF
sha256sum "$staged_apk" >"$staged_apk.sha256"
echo "[fdroid] unsigned APK: $staged_apk"
echo "[fdroid] metadata bundle: $archive"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_ID="com.trebuchetdynamics.fractal.forge"
FLUTTER_PIN="$PROJECT_ROOT/fdroid/flutter.version"
FLUTTER_VERSION="$(cat "$FLUTTER_PIN")"
SIGNING_CERT_SHA256="8d5f69b91dd44476ceaad141f1fa9f6abeccdfa20cd3f7bcdfe709df623878fd"
REPRO_BUILD_ROOT="/tmp/fractal-forge-reproducible"
VERSION=""
BUILD_NUMBER=""
COMMIT=""
OUTPUT_DIR="$PROJECT_ROOT/release-artifacts/fdroid"
METADATA_ONLY=0

usage() {
  cat <<'EOF'
Usage: scripts/build-fdroid.sh --version=X.Y.Z --build-number=N --commit=SHA [options]

Build and verify the unsigned ABI APKs that the official F-Droid buildserver
will reproduce, then create a ready-to-submit fdroiddata metadata bundle.

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

[[ "$FLUTTER_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "[fdroid] ERROR: could not extract pinned Flutter version from $FLUTTER_PIN" >&2; exit 1;
}
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

metadata="$METADATA_DIR/$PACKAGE_ID.yml"
cat >"$metadata" <<EOF
Categories:
  - Graphics
  - Multimedia
License: Apache-2.0
AuthorName: Trebuchet Dynamics
AuthorWebSite: https://trebuchetdynamics.com
WebSite: https://fractal.trebuchetdynamics.com
SourceCode: https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge
IssueTracker: https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge/-/issues
Changelog:
  https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge/-/blob/HEAD/CHANGELOG.md

AutoName: Fractal Forge

RepoType: git
Repo: https://gitlab.com/TrebuchetDynamics/flutter-fractal-forge.git

Builds:
EOF

render_build_block() {
  local abi="$1"
  local target="$2"
  local abi_code="$3"
  local version_code=$((BUILD_NUMBER * 10 + abi_code))

  cat >>"$metadata" <<EOF
  - versionName: $VERSION
    versionCode: $version_code
    commit: $COMMIT
    output: build/app/outputs/flutter-apk/app-$abi-release.apk
    binary:
      https://github.com/TrebuchetDynamics/flutter-fractal-forge/releases/download/v%v/fractal-forge-android-$abi-v%v.apk
    srclibs:
      - flutter@stable
    rm:
      - docs/qa/fractal-audits
      - integration_test
      - ios
      - linux
      - macos
      - test
      - web
      - windows
      - research
    prebuild:
      - flutterVersion=\$(cat fdroid/flutter.version)
      - '[[ \$flutterVersion ]]'
      - git -C \$\$flutter\$\$ checkout -f \$flutterVersion
      - export repo=$REPRO_BUILD_ROOT
      - rm -rf \$repo
      - cd ..
      - mv $PACKAGE_ID \$repo
      - pushd \$repo
      - export PUB_CACHE="\$(pwd)/.pub-cache"
      - \$\$flutter\$\$/bin/flutter config --no-analytics
      - \$\$flutter\$\$/bin/flutter pub get --enforce-lockfile
      - popd
      - mv \$repo $PACKAGE_ID
    scandelete:
      - .pub-cache
    build:
      - export repo=$REPRO_BUILD_ROOT
      - rm -rf \$repo
      - cd ..
      - mv $PACKAGE_ID \$repo
      - pushd \$repo
      - export PUB_CACHE="\$(pwd)/.pub-cache"
      - export FDROID_BUILD=1
      - \$\$flutter\$\$/bin/flutter build apk --release --split-per-abi --target-platform="$target"
        --build-name=\$\$VERSION\$\$ --build-number=\$(( \$\$VERCODE\$\$ / 10 ))
      - popd
      - mv \$repo $PACKAGE_ID
    ndk: r28c

EOF
}

render_build_block "armeabi-v7a" "android-arm" 1
render_build_block "arm64-v8a" "android-arm64" 2
render_build_block "x86_64" "android-x64" 3

current_version_code=$((BUILD_NUMBER * 10 + 3))
cat >>"$metadata" <<EOF
AllowedAPKSigningKeys: $SIGNING_CERT_SHA256

MaintainerNotes: |-
  FDROID_BUILD disables upstream signing so F-Droid can verify the three
  ABI-specific APKs against the developer-signed reference binaries. Release
  minification removes Flutter's unused Play Store deferred-component
  implementation; the app declares no deferred components or Play Core dependency.

AutoUpdateMode: Version
UpdateCheckMode: Tags ^v[0-9]+\\.[0-9]+\\.[0-9]+$
VercodeOperation:
  - '%c * 10 + 1'
  - '%c * 10 + 2'
  - '%c * 10 + 3'
UpdateCheckData: fdroid/version.properties|versionCode=(\\d+)|.|versionName=(.+)
CurrentVersion: $VERSION
CurrentVersionCode: $current_version_code
EOF

source_epoch="$(git -C "$PROJECT_ROOT" show -s --format=%ct "$COMMIT")"
archive="$OUTPUT_DIR/fractal-forge-fdroiddata-v$VERSION.tar.gz"
rm -f "$archive"
TZ=UTC tar --sort=name --mtime="@$source_epoch" --owner=0 --group=0 --numeric-owner \
  -C "$OUTPUT_DIR" -cf - fdroiddata | gzip -n >"$archive"
(
  cd "$(dirname "$archive")"
  sha256sum "$(basename "$archive")" >"$(basename "$archive").sha256"
)

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

ABIS=("armeabi-v7a" "arm64-v8a" "x86_64")
ABI_CODES=(1 2 3)

built_apk_for() {
  printf '%s/build/app/outputs/flutter-apk/app-%s-release.apk' "$PROJECT_ROOT" "$1"
}

build_apks() {
  local clean_output="${1:-0}"
  if (( clean_output == 1 )); then
    rm -rf "$PROJECT_ROOT/build"
  else
    rm -f "$PROJECT_ROOT"/build/app/outputs/flutter-apk/app-*-release.apk
  fi
  (
    cd "$PROJECT_ROOT"
    env FDROID_BUILD=1 "$FLUTTER_BIN" build apk --release --split-per-abi \
        --build-name="$VERSION" --build-number="$BUILD_NUMBER"
  )
}

verify_built_apks() {
  local index abi version_code built_apk
  for index in "${!ABIS[@]}"; do
    abi="${ABIS[$index]}"
    version_code=$((BUILD_NUMBER * 10 + ABI_CODES[$index]))
    built_apk="$(built_apk_for "$abi")"
    [[ -f "$built_apk" ]] || {
      echo "[fdroid] ERROR: Flutter did not produce $abi release APK" >&2; exit 1;
    }
    "$SCRIPT_DIR/verify-fdroid-apk.sh" "$built_apk" "$VERSION" "$version_code" "$abi"
  done
}

(
  cd "$PROJECT_ROOT"
  "$FLUTTER_BIN" pub get --enforce-lockfile
)
build_apks "$REPRODUCIBLE"
verify_built_apks

if (( REPRODUCIBLE == 1 )); then
  for abi in "${ABIS[@]}"; do
    cp "$(built_apk_for "$abi")" "$OUTPUT_DIR/.first-fdroid-build-$abi.apk"
  done
  build_apks 1
  verify_built_apks
  for abi in "${ABIS[@]}"; do
    first_apk="$OUTPUT_DIR/.first-fdroid-build-$abi.apk"
    built_apk="$(built_apk_for "$abi")"
    if ! cmp -s "$first_apk" "$built_apk"; then
      echo "[fdroid] ERROR: clean $abi F-Droid builds are not byte-for-byte reproducible" >&2
      sha256sum "$first_apk" "$built_apk" >&2
      rm -f "$OUTPUT_DIR"/.first-fdroid-build-*.apk
      exit 1
    fi
  done
  rm -f "$OUTPUT_DIR"/.first-fdroid-build-*.apk
  echo "[fdroid] reproducibility checks passed for all ABI APKs"
fi

for index in "${!ABIS[@]}"; do
  abi="${ABIS[$index]}"
  version_code=$((BUILD_NUMBER * 10 + ABI_CODES[$index]))
  built_apk="$(built_apk_for "$abi")"
  staged_apk="$OUTPUT_DIR/fractal-forge-fdroid-v$VERSION-$abi-unsigned.apk"
  cp "$built_apk" "$staged_apk"
  sha256="$(sha256sum "$staged_apk" | awk '{ print $1 }')"
  cat >"$staged_apk.provenance" <<EOF
version=$VERSION
base_build_number=$BUILD_NUMBER
version_code=$version_code
abi=$abi
commit=$COMMIT
sha256=$sha256
unsigned=true
flutter_version=$FLUTTER_VERSION
source_date_epoch=$source_epoch
EOF
  (
    cd "$(dirname "$staged_apk")"
    sha256sum "$(basename "$staged_apk")" >"$(basename "$staged_apk").sha256"
  )
  echo "[fdroid] unsigned APK: $staged_apk"
done
echo "[fdroid] metadata bundle: $archive"

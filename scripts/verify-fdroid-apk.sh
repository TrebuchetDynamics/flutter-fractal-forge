#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: scripts/verify-fdroid-apk.sh APK VERSION BUILD_NUMBER" >&2
  exit 2
fi

APK="$1"
EXPECTED_VERSION="$2"
EXPECTED_BUILD="$3"
EXPECTED_PACKAGE="com.trebuchetdynamics.fractal.forge"

[[ -f "$APK" ]] || { echo "[fdroid] ERROR: APK not found: $APK" >&2; exit 1; }
for tool in aapt apksigner unzip; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "[fdroid] ERROR: required Android tool not found: $tool" >&2
    exit 1
  }
done

badging="$(aapt dump badging "$APK")"
package_name="$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" <<<"$badging" | head -n1)"
version_code="$(sed -n "s/^package:.*versionCode='\([^']*\)'.*/\1/p" <<<"$badging" | head -n1)"
version_name="$(sed -n "s/^package:.*versionName='\([^']*\)'.*/\1/p" <<<"$badging" | head -n1)"

[[ "$package_name" == "$EXPECTED_PACKAGE" ]] || {
  echo "[fdroid] ERROR: package mismatch: $package_name" >&2; exit 1;
}
[[ "$version_name" == "$EXPECTED_VERSION" ]] || {
  echo "[fdroid] ERROR: versionName mismatch: $version_name != $EXPECTED_VERSION" >&2; exit 1;
}
[[ "$version_code" == "$EXPECTED_BUILD" ]] || {
  echo "[fdroid] ERROR: versionCode mismatch: $version_code != $EXPECTED_BUILD" >&2; exit 1;
}

abis="$(unzip -Z1 "$APK" | sed -n 's#^lib/\([^/]*\)/.*#\1#p' | sort -u | paste -sd, -)"
[[ "$abis" == "arm64-v8a,armeabi-v7a,x86_64" ]] || {
  echo "[fdroid] ERROR: universal APK ABI set mismatch: $abis" >&2; exit 1;
}

if apksigner verify "$APK" >/dev/null 2>&1; then
  echo "[fdroid] ERROR: F-Droid APK must be unsigned; F-Droid signs it on isolated infrastructure" >&2
  exit 1
fi

echo "[fdroid] verified unsigned universal APK: $EXPECTED_PACKAGE $EXPECTED_VERSION+$EXPECTED_BUILD ($abis)"

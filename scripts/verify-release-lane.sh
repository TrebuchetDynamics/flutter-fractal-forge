#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-/home/xel/flutter/bin/flutter}"

cd "$(dirname "$0")/.."

"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" test --reporter compact
"$FLUTTER_BIN" build apk --release

APK="build/app/outputs/flutter-apk/app-release.apk"
echo "artifact_path=$APK"
echo "artifact_size=$(du -h "$APK" | cut -f1)"
echo "artifact_sha256=$(sha256sum "$APK" | awk '{print $1}')"

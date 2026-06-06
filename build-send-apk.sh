#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: ./build-send-apk.sh [--release|--debug] [-d DEVICE_ID]

Build an Android APK and install it on a connected device.
Defaults to --release.

Options:
  --release        Build release APK (default)
  --debug          Build debug APK
  -d, --device ID  Target adb device ID when multiple devices are connected
  -h, --help       Show this help

Environment:
  FLUTTER_BIN      Override flutter executable path
  ADB_BIN          Override adb executable path
USAGE
}

mode="release"
device_id=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release)
      mode="release"
      shift
      ;;
    --debug)
      mode="debug"
      shift
      ;;
    -d|--device)
      if [[ $# -lt 2 || "$2" == -* ]]; then
        echo "error: $1 requires a device ID" >&2
        exit 2
      fi
      device_id="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

if [[ -n "${FLUTTER_BIN:-}" ]]; then
  flutter_bin="$FLUTTER_BIN"
elif command -v flutter >/dev/null 2>&1; then
  flutter_bin="$(command -v flutter)"
elif [[ -x /home/xel/flutter/bin/flutter ]]; then
  flutter_bin="/home/xel/flutter/bin/flutter"
else
  echo "error: flutter not found; set FLUTTER_BIN=/path/to/flutter" >&2
  exit 1
fi

if [[ -n "${ADB_BIN:-}" ]]; then
  adb_bin="$ADB_BIN"
elif command -v adb >/dev/null 2>&1; then
  adb_bin="$(command -v adb)"
elif [[ -x /usr/lib/android-sdk/platform-tools/adb ]]; then
  adb_bin="/usr/lib/android-sdk/platform-tools/adb"
else
  echo "error: adb not found; set ADB_BIN=/path/to/adb" >&2
  exit 1
fi

if [[ -z "$device_id" ]]; then
  mapfile -t devices < <("$adb_bin" devices | awk 'NR > 1 && $2 == "device" {print $1}')
  case "${#devices[@]}" in
    0)
      echo "error: no connected adb device found" >&2
      "$adb_bin" devices >&2
      exit 1
      ;;
    1)
      device_id="${devices[0]}"
      ;;
    *)
      echo "error: multiple adb devices connected; choose one with -d DEVICE_ID" >&2
      "$adb_bin" devices >&2
      exit 1
      ;;
  esac
fi

apk_path="build/app/outputs/flutter-apk/app-${mode}.apk"

echo "Building ${mode} APK..."
"$flutter_bin" build apk "--${mode}"

if [[ ! -f "$apk_path" ]]; then
  echo "error: expected APK not found: $apk_path" >&2
  exit 1
fi

echo "Installing $apk_path on $device_id..."
"$adb_bin" -s "$device_id" install -r "$apk_path"

echo "Installed ${mode} APK on $device_id"

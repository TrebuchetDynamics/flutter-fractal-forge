#!/usr/bin/env bash
set -euo pipefail

# Build a signed Android App Bundle (.aab) for Google Play Console upload.
#
# Usage:
#   scripts/build-play-console.sh [options] [flutter build appbundle args...]
#
# Options:
#   --output-dir DIR   Output folder for upload-ready artifacts
#                      (default: play-console-upload)
#   --skip-pub-get     Skip `flutter pub get`
#   --help             Show help
#
# Any unknown argument is forwarded to:
#   flutter build appbundle --release

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export PATH="$HOME/.local/bin:/home/xel/flutter/bin:$PATH"

OUTPUT_DIR="play-console-upload"
RUN_PUB_GET=1
FORWARDED_ARGS=()

log() { echo "[build-play-console] $*"; }
die() { echo "[build-play-console] ERROR: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Build a signed Android App Bundle (.aab) for Google Play Console.

Usage:
  scripts/build-play-console.sh [options] [flutter build args...]

Options:
  --output-dir DIR   Output folder for upload-ready artifacts
                     (default: play-console-upload)
  --skip-pub-get     Skip `flutter pub get`
  --help             Show this help

Examples:
  scripts/build-play-console.sh
  scripts/build-play-console.sh --build-name 1.2.0 --build-number 42
  scripts/build-play-console.sh --output-dir release/play --dart-define=SAFE_MODE=false
EOF
}

read_prop() {
  local key="$1"
  local file="$2"
  awk -F= -v wanted="$key" '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
      k = $1
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)
      if (k == wanted) {
        sub(/^[^=]*=/, "", $0)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0
        exit
      }
    }
  ' "$file"
}

resolve_store_file() {
  local raw="$1"
  local expanded="$raw"

  if [[ "$expanded" == "~/"* ]]; then
    expanded="$HOME/${expanded#~/}"
  fi

  if [[ "$expanded" = /* ]]; then
    [[ -f "$expanded" ]] && { echo "$expanded"; return 0; }
    return 1
  fi

  local candidate
  for candidate in \
    "$PROJECT_ROOT/android/app/$expanded" \
    "$PROJECT_ROOT/android/$expanded" \
    "$PROJECT_ROOT/$expanded"; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      [[ $# -ge 2 ]] || die "--output-dir requires a value"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --skip-pub-get)
      RUN_PUB_GET=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        FORWARDED_ARGS+=("$1")
        shift
      done
      ;;
    *)
      FORWARDED_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "$OUTPUT_DIR" != /* ]]; then
  OUTPUT_DIR="$PROJECT_ROOT/$OUTPUT_DIR"
fi

command -v flutter >/dev/null 2>&1 || die "flutter not found in PATH"
command -v find >/dev/null 2>&1 || die "find not found in PATH"

KEY_PROPS="$PROJECT_ROOT/android/key.properties"
[[ -f "$KEY_PROPS" ]] || die "Missing android/key.properties. Copy android/key.properties.example and set upload keystore values."

STORE_PASSWORD="$(read_prop "storePassword" "$KEY_PROPS")"
KEY_PASSWORD="$(read_prop "keyPassword" "$KEY_PROPS")"
KEY_ALIAS="$(read_prop "keyAlias" "$KEY_PROPS")"
STORE_FILE_RAW="$(read_prop "storeFile" "$KEY_PROPS")"

[[ -n "$STORE_PASSWORD" ]] || die "Missing storePassword in android/key.properties"
[[ -n "$KEY_PASSWORD" ]] || die "Missing keyPassword in android/key.properties"
[[ -n "$KEY_ALIAS" ]] || die "Missing keyAlias in android/key.properties"
[[ -n "$STORE_FILE_RAW" ]] || die "Missing storeFile in android/key.properties"

STORE_FILE_RESOLVED="$(resolve_store_file "$STORE_FILE_RAW")" || die "Keystore file not found from storeFile=$STORE_FILE_RAW"
log "Using upload key alias: $KEY_ALIAS"
log "Using keystore file: $STORE_FILE_RESOLVED"

cd "$PROJECT_ROOT"

if [[ "$RUN_PUB_GET" -eq 1 ]]; then
  log "Running flutter pub get..."
  flutter pub get
fi

log "Building release app bundle..."
flutter build appbundle --release "${FORWARDED_ARGS[@]}"

BUNDLE_ROOT="$PROJECT_ROOT/build/app/outputs/bundle"
[[ -d "$BUNDLE_ROOT" ]] || die "Bundle output directory not found: $BUNDLE_ROOT"

LATEST_BUNDLE="$(
  find "$BUNDLE_ROOT" -type f -name '*.aab' -printf '%T@ %p\n' \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-
)"

[[ -n "$LATEST_BUNDLE" ]] || die "No .aab produced under $BUNDLE_ROOT"

PUBSPEC_VERSION="$(awk '/^version:[[:space:]]*/ { print $2; exit }' "$PROJECT_ROOT/pubspec.yaml")"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
VERSION_TAG="${PUBSPEC_VERSION:-unknown}"
ARTIFACT_NAME="fractal-forge-${VERSION_TAG}-${TIMESTAMP}.aab"

mkdir -p "$OUTPUT_DIR"
DEST_AAB="$OUTPUT_DIR/$ARTIFACT_NAME"
cp "$LATEST_BUNDLE" "$DEST_AAB"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$DEST_AAB" > "${DEST_AAB}.sha256"
fi
printf '%s\n' "$DEST_AAB" > "$OUTPUT_DIR/LATEST_AAB.txt"

log "Bundle ready for Play Console upload:"
log "$DEST_AAB"
if [[ -f "${DEST_AAB}.sha256" ]]; then
  log "${DEST_AAB}.sha256"
fi

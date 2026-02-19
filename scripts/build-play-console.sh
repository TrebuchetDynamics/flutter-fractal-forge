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
#   --expected-sha1 S  Expected upload certificate SHA1 fingerprint.
#                      Also supported via PLAY_UPLOAD_CERT_SHA1 env var or
#                      android/play-upload-cert-sha1.txt.
#   --no-verify-sha1   Skip upload certificate SHA1 verification.
#   --skip-pub-get     Skip `flutter pub get` (build runs with --no-pub)
#   --help             Show help
#
# Any unknown argument is forwarded to:
#   flutter build appbundle --release

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export PATH="$HOME/.local/bin:/home/xel/flutter/bin:$PATH"

OUTPUT_DIR="play-console-upload"
RUN_PUB_GET=1
VERIFY_SHA1=1
EXPECTED_SHA1="${PLAY_UPLOAD_CERT_SHA1:-}"
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
  --expected-sha1 S  Expected upload certificate SHA1 fingerprint
  --no-verify-sha1   Skip upload certificate SHA1 verification
  --skip-pub-get     Skip `flutter pub get` (build runs with --no-pub)
  --help             Show this help

Build number behavior:
  - If --build-number is provided, that value is used.
  - Otherwise, this script auto-increments from the highest of:
    pubspec.yaml version +N, android/local.properties flutter.versionCode,
    and play-console-upload/LAST_BUILD_NUMBER.txt.

Examples:
  scripts/build-play-console.sh
  scripts/build-play-console.sh --build-name 1.2.0 --build-number 42
  scripts/build-play-console.sh --output-dir release/play --dart-define=SAFE_MODE=false
EOF
}

normalize_sha1() {
  echo "$1" | tr '[:lower:]' '[:upper:]' | tr -cd '0-9A-F'
}

format_sha1() {
  local normalized
  normalized="$(normalize_sha1 "$1")"
  if [[ ${#normalized} -ne 40 ]]; then
    echo "$1"
    return 0
  fi

  local out=""
  local i
  for ((i = 0; i < 40; i += 2)); do
    if [[ -n "$out" ]]; then
      out+=":"
    fi
    out+="${normalized:$i:2}"
  done
  echo "$out"
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

get_keystore_sha1() {
  local keystore_file="$1"
  local key_alias="$2"
  local store_pass="$3"
  local key_pass="$4"
  local raw_sha1

  raw_sha1="$(
    keytool -list -v \
      -keystore "$keystore_file" \
      -storepass "$store_pass" \
      -alias "$key_alias" \
      -keypass "$key_pass" 2>/dev/null \
      | awk '/SHA1:/ { print $2; exit }'
  )"

  [[ -n "$raw_sha1" ]] || die "Unable to read SHA1 from keystore=$keystore_file alias=$key_alias (check key.properties credentials)."
  echo "$raw_sha1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      [[ $# -ge 2 ]] || die "--output-dir requires a value"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --expected-sha1)
      [[ $# -ge 2 ]] || die "--expected-sha1 requires a value"
      EXPECTED_SHA1="$2"
      shift 2
      ;;
    --expected-sha1=*)
      EXPECTED_SHA1="${1#--expected-sha1=}"
      shift
      ;;
    --no-verify-sha1)
      VERIFY_SHA1=0
      shift
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
LAST_BUILD_MARKER="$OUTPUT_DIR/LAST_BUILD_NUMBER.txt"
REGISTRANT_FILE="$PROJECT_ROOT/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
REGISTRANT_BACKUP=""
RESTORE_REGISTRANT=0

command -v flutter >/dev/null 2>&1 || die "flutter not found in PATH"
command -v find >/dev/null 2>&1 || die "find not found in PATH"
command -v keytool >/dev/null 2>&1 || die "keytool not found in PATH (install JDK)"

KEY_PROPS="$PROJECT_ROOT/android/key.properties"
[[ -f "$KEY_PROPS" ]] || die "Missing android/key.properties. Copy android/key.properties.example and set upload keystore values."
EXPECTED_SHA1_FILE="$PROJECT_ROOT/android/play-upload-cert-sha1.txt"

if [[ -z "$EXPECTED_SHA1" && -f "$EXPECTED_SHA1_FILE" ]]; then
  EXPECTED_SHA1="$(head -n 1 "$EXPECTED_SHA1_FILE" | tr -d '\r\n')"
fi

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

ACTUAL_SHA1_RAW="$(get_keystore_sha1 "$STORE_FILE_RESOLVED" "$KEY_ALIAS" "$STORE_PASSWORD" "$KEY_PASSWORD")"
ACTUAL_SHA1_NORM="$(normalize_sha1 "$ACTUAL_SHA1_RAW")"
ACTUAL_SHA1_FMT="$(format_sha1 "$ACTUAL_SHA1_NORM")"
log "Signing certificate SHA1: $ACTUAL_SHA1_FMT"

if [[ "$VERIFY_SHA1" -eq 1 ]]; then
  if [[ -n "$EXPECTED_SHA1" ]]; then
    EXPECTED_SHA1_NORM="$(normalize_sha1 "$EXPECTED_SHA1")"
    [[ ${#EXPECTED_SHA1_NORM} -eq 40 ]] || die "Invalid expected SHA1: $EXPECTED_SHA1"
    if [[ "$ACTUAL_SHA1_NORM" != "$EXPECTED_SHA1_NORM" ]]; then
      die "Upload key SHA1 mismatch. Expected $(format_sha1 "$EXPECTED_SHA1_NORM"), got $ACTUAL_SHA1_FMT. Update android/key.properties to the correct upload keystore."
    fi
    log "Upload key SHA1 verified against expected fingerprint."
  else
    log "No expected SHA1 configured; set --expected-sha1, PLAY_UPLOAD_CERT_SHA1, or android/play-upload-cert-sha1.txt"
  fi
else
  log "Skipping upload certificate SHA1 verification (--no-verify-sha1)"
fi

cleanup() {
  if [[ "$RESTORE_REGISTRANT" -eq 1 && -n "$REGISTRANT_BACKUP" && -f "$REGISTRANT_BACKUP" ]]; then
    cp "$REGISTRANT_BACKUP" "$REGISTRANT_FILE" >/dev/null 2>&1 || true
    rm -f "$REGISTRANT_BACKUP" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

sanitize_release_registrant() {
  if [[ ! -f "$REGISTRANT_FILE" ]]; then
    return 0
  fi

  if ! grep -q 'dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin()' "$REGISTRANT_FILE"; then
    return 0
  fi

  REGISTRANT_BACKUP="$(mktemp)"
  cp "$REGISTRANT_FILE" "$REGISTRANT_BACKUP"
  sed -i '/dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin()/d' "$REGISTRANT_FILE"

  if grep -q 'dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin()' "$REGISTRANT_FILE"; then
    die "Failed to sanitize GeneratedPluginRegistrant.java for release build"
  fi

  RESTORE_REGISTRANT=1
  log "Temporarily removed integration_test native registration for release build compatibility"
}

cd "$PROJECT_ROOT"

if [[ "$RUN_PUB_GET" -eq 1 ]]; then
  log "Running flutter pub get..."
  flutter pub get
fi

# Always force --no-pub for the build step so generated plugin registrants
# are not rewritten in non-release mode during this script execution.
SANITIZED_ARGS=()
for arg in "${FORWARDED_ARGS[@]}"; do
  case "$arg" in
    --pub|--no-pub) ;;
    *) SANITIZED_ARGS+=("$arg") ;;
  esac
done
FORWARDED_ARGS=("${SANITIZED_ARGS[@]}" "--no-pub")

sanitize_release_registrant

PUBSPEC_VERSION_FULL="$(awk '/^version:[[:space:]]*/ { print $2; exit }' "$PROJECT_ROOT/pubspec.yaml")"
PUBSPEC_VERSION_NAME="$PUBSPEC_VERSION_FULL"
if [[ "$PUBSPEC_VERSION_NAME" == *"+"* ]]; then
  PUBSPEC_VERSION_NAME="${PUBSPEC_VERSION_NAME%%+*}"
fi

EXPLICIT_BUILD_NUMBER=""
for ((i = 0; i < ${#FORWARDED_ARGS[@]}; i++)); do
  arg="${FORWARDED_ARGS[$i]}"
  case "$arg" in
    --build-number)
      if ((i + 1 >= ${#FORWARDED_ARGS[@]})); then
        die "--build-number passed without a value"
      fi
      EXPLICIT_BUILD_NUMBER="${FORWARDED_ARGS[$((i + 1))]}"
      ;;
    --build-number=*)
      EXPLICIT_BUILD_NUMBER="${arg#--build-number=}"
      ;;
  esac
done

USED_BUILD_NUMBER=""
if [[ -n "$EXPLICIT_BUILD_NUMBER" ]]; then
  [[ "$EXPLICIT_BUILD_NUMBER" =~ ^[0-9]+$ ]] || die "Invalid --build-number: $EXPLICIT_BUILD_NUMBER"
  if ((EXPLICIT_BUILD_NUMBER > 2100000000)); then
    die "Build number $EXPLICIT_BUILD_NUMBER exceeds Play Console limit (2100000000)"
  fi
  USED_BUILD_NUMBER="$EXPLICIT_BUILD_NUMBER"
  log "Using explicit build number: $USED_BUILD_NUMBER"
else
  highest=0
  got_source=0
  sources=()

  if [[ "$PUBSPEC_VERSION_FULL" =~ \+([0-9]+)$ ]]; then
    pubspec_build="${BASH_REMATCH[1]}"
    sources+=("pubspec:$pubspec_build")
    if ((pubspec_build > highest)); then
      highest="$pubspec_build"
    fi
    got_source=1
  fi

  LOCAL_PROPS="$PROJECT_ROOT/android/local.properties"
  if [[ -f "$LOCAL_PROPS" ]]; then
    local_build="$(read_prop "flutter.versionCode" "$LOCAL_PROPS" || true)"
    if [[ "$local_build" =~ ^[0-9]+$ ]]; then
      sources+=("local.properties:$local_build")
      if ((local_build > highest)); then
        highest="$local_build"
      fi
      got_source=1
    fi
  fi

  if [[ -f "$LAST_BUILD_MARKER" ]]; then
    last_build="$(head -n 1 "$LAST_BUILD_MARKER" | tr -d '[:space:]')"
    if [[ "$last_build" =~ ^[0-9]+$ ]]; then
      sources+=("last-script-run:$last_build")
      if ((last_build > highest)); then
        highest="$last_build"
      fi
      got_source=1
    fi
  fi

  if ((got_source == 1)); then
    USED_BUILD_NUMBER="$((highest + 1))"
    log "Auto build number: $USED_BUILD_NUMBER (from highest of ${sources[*]})"
  else
    USED_BUILD_NUMBER="1"
    log "Auto build number: $USED_BUILD_NUMBER (no existing source found)"
  fi

  if ((USED_BUILD_NUMBER > 2100000000)); then
    die "Auto build number $USED_BUILD_NUMBER exceeds Play Console limit (2100000000)"
  fi

  FORWARDED_ARGS+=("--build-number=$USED_BUILD_NUMBER")
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

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
VERSION_TAG="${PUBSPEC_VERSION_NAME:-unknown}"
VERSION_TAG="${VERSION_TAG//[^0-9A-Za-z._-]/_}"
ARTIFACT_NAME="fractal-forge-v${VERSION_TAG}-b${USED_BUILD_NUMBER}-${TIMESTAMP}.aab"

mkdir -p "$OUTPUT_DIR"
DEST_AAB="$OUTPUT_DIR/$ARTIFACT_NAME"
cp "$LATEST_BUNDLE" "$DEST_AAB"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$DEST_AAB" > "${DEST_AAB}.sha256"
fi
printf '%s\n' "$DEST_AAB" > "$OUTPUT_DIR/LATEST_AAB.txt"
printf '%s\n' "$USED_BUILD_NUMBER" > "$LAST_BUILD_MARKER"
cat > "$OUTPUT_DIR/LATEST_BUILD_INFO.txt" <<EOF
versionName=${PUBSPEC_VERSION_NAME:-unknown}
buildNumber=$USED_BUILD_NUMBER
signingSha1=$ACTUAL_SHA1_FMT
sourceAab=$LATEST_BUNDLE
outputAab=$DEST_AAB
EOF

log "Bundle ready for Play Console upload:"
log "$DEST_AAB"
if [[ -f "${DEST_AAB}.sha256" ]]; then
  log "${DEST_AAB}.sha256"
fi

#!/usr/bin/env bash
# One-command Google Play release pipeline for this repository.
#
# Order is deliberately fail-closed and matches the documented pipeline:
#
#   1. identity preflight   version/build match fdroid/version.properties,
#                           tree is clean, the release tag is not elsewhere
#   2. Play preflight       the version code is not already consumed
#   3. shared offline gate  scripts/ci/offline-gate.sh (pinned SDK + lockfile)
#   4. device gate          scripts/pre-release-gate.sh on the designated target
#   5. build + upload       scripts/build-upload-playstore.sh (the only writer)
#   6. independent readback scripts/ci/play-readback.sh
#   7. evidence             AAB copy, release-play-evidence.json, record stub
#
# A failed gate stops before the upload. A failed readback never triggers a
# second upload: the edit may already be committed, so reconcile first.
#
# Usage: scripts/release-play.sh [options]
#   --version X.Y.Z            default: versionName in fdroid/version.properties
#   --build-number N           default: versionCode in fdroid/version.properties
#   --track TRACK              default: $PLAY_TRACK or production
#   --release-status STATUS    default: $PLAY_RELEASE_STATUS or completed
#   --artifact-dir DIR         default: release-artifacts/play-<version>
#   --device ID                default: $ANDROID_DEVICE
#   --disposable-device ID     default: $ANDROID_DISPOSABLE_DEVICE
#   --soak-seconds N           forwarded to the device gate (default: 300)
#   --play-status-json FILE    use recorded play-status JSON instead of the API
#   --skip-gate                skip the shared offline gate (recorded as skipped)
#   --skip-device-gate         skip the device gate (recorded as skipped)
#   --allow-dirty              permit an uncommitted tree (recorded as dirty)
#   --dry-run                  print the plan; no build, network or upload
#   --help
#
# Exit codes: 0 released and read back, 1 a gate/upload/readback failed,
# 2 the request was refused before any publication.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

PLAY_IDENTITY_FILE="$ROOT/fdroid/version.properties"
VERSION=""
BUILD_NUMBER=""
TRACK="${PLAY_TRACK:-production}"
RELEASE_STATUS="${PLAY_RELEASE_STATUS:-completed}"
ARTIFACT_DIR=""
DEVICE="${ANDROID_DEVICE:-}"
DISPOSABLE_DEVICE="${ANDROID_DISPOSABLE_DEVICE:-}"
SOAK_SECONDS=300
PLAY_STATUS_JSON=""
RUN_GATE=1
RUN_DEVICE_GATE=1
ALLOW_DIRTY=0
DRY_RUN=0

log() { echo "[release-play] $*" >&2; }
warn() { echo "[release-play] WARNING: $*" >&2; }
die() { echo "[release-play] ERROR: $*" >&2; exit 2; }

usage() {
  sed -n '2,42p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) [[ $# -ge 2 ]] || die "--version requires a value"; VERSION="$2"; shift 2 ;;
    --version=*) VERSION="${1#*=}"; shift ;;
    --build-number) [[ $# -ge 2 ]] || die "--build-number requires a value"; BUILD_NUMBER="$2"; shift 2 ;;
    --build-number=*) BUILD_NUMBER="${1#*=}"; shift ;;
    --track) [[ $# -ge 2 ]] || die "--track requires a value"; TRACK="$2"; shift 2 ;;
    --track=*) TRACK="${1#*=}"; shift ;;
    --release-status) [[ $# -ge 2 ]] || die "--release-status requires a value"; RELEASE_STATUS="$2"; shift 2 ;;
    --release-status=*) RELEASE_STATUS="${1#*=}"; shift ;;
    --artifact-dir) [[ $# -ge 2 ]] || die "--artifact-dir requires a value"; ARTIFACT_DIR="$2"; shift 2 ;;
    --artifact-dir=*) ARTIFACT_DIR="${1#*=}"; shift ;;
    --device) [[ $# -ge 2 ]] || die "--device requires a value"; DEVICE="$2"; shift 2 ;;
    --device=*) DEVICE="${1#*=}"; shift ;;
    --disposable-device) [[ $# -ge 2 ]] || die "--disposable-device requires a value"; DISPOSABLE_DEVICE="$2"; shift 2 ;;
    --disposable-device=*) DISPOSABLE_DEVICE="${1#*=}"; shift ;;
    --soak-seconds) [[ $# -ge 2 ]] || die "--soak-seconds requires a value"; SOAK_SECONDS="$2"; shift 2 ;;
    --soak-seconds=*) SOAK_SECONDS="${1#*=}"; shift ;;
    --play-status-json) [[ $# -ge 2 ]] || die "--play-status-json requires a value"; PLAY_STATUS_JSON="$2"; shift 2 ;;
    --play-status-json=*) PLAY_STATUS_JSON="${1#*=}"; shift ;;
    --skip-gate) RUN_GATE=0; shift ;;
    --skip-device-gate) RUN_DEVICE_GATE=0; shift ;;
    --allow-dirty) ALLOW_DIRTY=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ "$SOAK_SECONDS" =~ ^[0-9]+$ ]] || die "--soak-seconds must be an integer"
[[ -f "$PLAY_IDENTITY_FILE" ]] || die "missing $PLAY_IDENTITY_FILE"
[[ -f "$ROOT/pubspec.yaml" ]] || die "missing pubspec.yaml"

# ---------------------------------------------------------------- identity ---
PINNED_FILE_VERSION="$(awk -F= '$1=="versionName" {print $2}' "$PLAY_IDENTITY_FILE" | tr -d '[:space:]')"
PINNED_BUILD_NUMBER="$(awk -F= '$1=="versionCode" {print $2}' "$PLAY_IDENTITY_FILE" | tr -d '[:space:]')"
VERSION="${VERSION:-$PINNED_FILE_VERSION}"
BUILD_NUMBER="${BUILD_NUMBER:-$PINNED_BUILD_NUMBER}"

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[1-9][0-9]*$ ]] || die "invalid --version: $VERSION"
[[ "$BUILD_NUMBER" =~ ^[1-9][0-9]*$ ]] || die "invalid --build-number: $BUILD_NUMBER"
[[ "${VERSION##*.}" == "$BUILD_NUMBER" ]] ||
  die "version $VERSION does not end in build number $BUILD_NUMBER"
[[ "$VERSION" == "$PINNED_FILE_VERSION" && "$BUILD_NUMBER" == "$PINNED_BUILD_NUMBER" ]] ||
  die "requested $VERSION/$BUILD_NUMBER does not match $PLAY_IDENTITY_FILE ($PINNED_FILE_VERSION/$PINNED_BUILD_NUMBER); commit the release preparation first"

PUBSPEC_VERSION="$(awk '/^version:[[:space:]]*/ {print $2; exit}' "$ROOT/pubspec.yaml")"
PUBSPEC_MAJOR_MINOR="${PUBSPEC_VERSION%%+*}"
PUBSPEC_MAJOR_MINOR="${PUBSPEC_MAJOR_MINOR%.*}"
[[ "$VERSION" == "$PUBSPEC_MAJOR_MINOR".* ]] ||
  die "version $VERSION does not match pubspec major.minor $PUBSPEC_MAJOR_MINOR"

COMMIT="$(git rev-parse HEAD)"
DIRTY=0
if [[ -n "$(git status --porcelain)" ]]; then
  DIRTY=1
fi
if [[ "$DIRTY" -eq 1 ]]; then
  [[ "$ALLOW_DIRTY" -eq 1 ]] || die "working tree is dirty; commit or pass --allow-dirty"
fi
if git rev-parse --verify --quiet "refs/tags/v$VERSION" >/dev/null; then
  [[ "$(git rev-list -n1 "v$VERSION")" == "$COMMIT" ]] ||
    die "tag v$VERSION already points at different code"
fi

# -------------------------------------------------------------- preflight ---
check_tools() {
  local tool missing=()
  for tool in git curl openssl python3 java sha256sum; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done
  [[ ${#missing[@]} -eq 0 ]] || die "required tools unavailable: ${missing[*]}"
}

check_android_signing() {
  local props="$ROOT/android/key.properties" store_file resolved
  [[ -f "$props" ]] || die "missing $props (Android upload signing)"
  store_file="$(awk -F= '$1=="storeFile" {print $2}' "$props" | tr -d '[:space:]')"
  [[ -n "$store_file" ]] || die "android/key.properties has no storeFile"
  resolved="${store_file/#\~/$HOME}"
  if [[ "$resolved" != /* ]]; then
    resolved="$ROOT/android/$resolved"
  fi
  [[ -f "$resolved" ]] || die "upload keystore not found from storeFile=$store_file"
}

check_play_credentials() {
  local key_json="${PLAY_SERVICE_ACCOUNT_JSON:-play-console-upload/play-service-account.json}"
  [[ -f "$key_json" ]] || die "Play service account JSON unavailable: $key_json"
  python3 - "$key_json" <<'PY' || die "Play service account JSON is not usable"
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data.get("client_email") and data.get("private_key"), "missing client_email/private_key"
PY
}

# Echo the recorded/live Play status JSON for track $TRACK.
play_status() {
  if [[ -n "$PLAY_STATUS_JSON" ]]; then
    [[ -f "$PLAY_STATUS_JSON" ]] || die "recorded Play status not found: $PLAY_STATUS_JSON"
    cat "$PLAY_STATUS_JSON"
    return 0
  fi
  scripts/ci/play-status.sh --track "$TRACK"
}

# Refuse a consumed or descending version code. Prints a one-line verdict.
check_play_version_code() {
  local status_json="$1"
  PLAY_STATUS_JSON_TEXT="$status_json" BUILD_NUMBER="$BUILD_NUMBER" TRACK="$TRACK" \
    python3 - <<'PY' || exit 2
import json, os, sys

try:
    status = json.loads(os.environ["PLAY_STATUS_JSON_TEXT"])
except json.JSONDecodeError as error:
    sys.exit(f"[release-play] ERROR: Play status is not JSON: {error}")
build = int(os.environ["BUILD_NUMBER"])
track = os.environ["TRACK"]
uploaded = [int(code) for code in status.get("uploadedVersionCodes", [])]
on_track = [int(code) for code in status.get("trackVersionCodes", [])]
latest = max(uploaded, default=0)
if build in uploaded or build in on_track:
    sys.exit(f"[release-play] ERROR: version code {build} is already consumed on Play "
             f"(latest consumed {latest}); choose the next build number")
if latest and build <= latest:
    sys.exit(f"[release-play] ERROR: build number {build} is not newer than the latest "
             f"consumed version code {latest}")
gap = build - latest if latest else build
print(f"version code {build} is free on track {track} "
      f"(latest consumed {latest}, gap {gap})")
PY
}

ARTIFACT_DIR="${ARTIFACT_DIR:-$ROOT/release-artifacts/play-$VERSION}"
GATE_DIR="$ARTIFACT_DIR/gates"

log "release identity: $VERSION ($BUILD_NUMBER) from $COMMIT"
log "destination: Play track $TRACK, status $RELEASE_STATUS"
log "artifact dir: $ARTIFACT_DIR"
[[ "$DIRTY" -eq 1 ]] && warn "working tree is dirty (--allow-dirty)"

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "DRY RUN: no build, network call or publication will happen"
else
  check_tools
  check_android_signing
  check_play_credentials
fi

if [[ -n "$PLAY_STATUS_JSON" && ! -f "$PLAY_STATUS_JSON" ]]; then
  die "recorded Play status not found: $PLAY_STATUS_JSON"
fi
if [[ "$DRY_RUN" -eq 1 && -z "$PLAY_STATUS_JSON" ]]; then
  log "DRY RUN: skipping the live Play status query"
else
  STATUS_JSON="$(play_status)" || die "could not read Play status"
  VERSION_VERDICT="$(check_play_version_code "$STATUS_JSON")" || exit 2
  log "$VERSION_VERDICT"
fi

plan_lines=(
  "1/6 identity preflight"
  "2/6 Play version-code preflight"
  "$([[ "$RUN_GATE" -eq 1 ]] && echo "3/6 shared offline gate" || echo "3/6 shared offline gate SKIPPED")"
  "$([[ "$RUN_DEVICE_GATE" -eq 1 ]] && echo "4/6 device gate on ${DEVICE:-<unset>}" || echo "4/6 device gate SKIPPED")"
  "5/6 build signed AAB and upload to $TRACK/$RELEASE_STATUS"
  "6/6 independent Play readback and evidence archive"
)
if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '%s\n' "${plan_lines[@]}"
  exit 0
fi

# ------------------------------------------------------------------ gates ---
if [[ "$RUN_GATE" -eq 1 ]]; then
  log "shared offline gate"
  mkdir -p "$GATE_DIR"
  if ! scripts/ci/offline-gate.sh --json --log-dir "$GATE_DIR/offline" >"$GATE_DIR/offline-gate.json" 2>"$GATE_DIR/offline-gate.log"; then
    tail -n 20 "$GATE_DIR/offline-gate.log" >&2 || true
    die "shared offline gate failed; nothing was published (see $GATE_DIR/offline-gate.json)"
  fi
  log "shared offline gate passed"
else
  warn "shared offline gate skipped by request"
fi

if [[ "$RUN_DEVICE_GATE" -eq 1 ]]; then
  [[ -n "$DEVICE" ]] || die "the device gate needs --device or ANDROID_DEVICE (or pass --skip-device-gate)"
  [[ -n "$DISPOSABLE_DEVICE" ]] ||
    die "the device gate needs --disposable-device or ANDROID_DISPOSABLE_DEVICE confirming the whole device is disposable"
  [[ "$DEVICE" == "$DISPOSABLE_DEVICE" ]] ||
    die "--device and --disposable-device must name the same target"
  log "device gate on $DEVICE"
  mkdir -p "$GATE_DIR"
  if ! scripts/pre-release-gate.sh --device "$DEVICE" --disposable-device "$DISPOSABLE_DEVICE" \
      --build-name "$VERSION" --build-number "$BUILD_NUMBER" \
      --soak-seconds "$SOAK_SECONDS" --skip-host \
      --log-dir "$GATE_DIR/device" >"$GATE_DIR/device-gate.log" 2>&1; then
    tail -n 30 "$GATE_DIR/device-gate.log" >&2 || true
    die "device gate failed; nothing was published (see $GATE_DIR/device-gate.log)"
  fi
  log "device gate passed"
else
  warn "device gate skipped by request"
fi

# ----------------------------------------------------------- build + upload ---
mkdir -p "$ARTIFACT_DIR"
RECEIPT="$ARTIFACT_DIR/play-publication-receipt.json"
log "building and uploading the signed AAB (this is the only publishing step)"
if ! PLAY_TRACK="$TRACK" PLAY_RELEASE_STATUS="$RELEASE_STATUS" PLAY_RECEIPT_PATH="$RECEIPT" \
    scripts/build-upload-playstore.sh \
      --build-number="$BUILD_NUMBER" \
      --expected-version "$VERSION" --expected-build-number "$BUILD_NUMBER"; then
  die "build/upload failed; check scripts/ci/play-status.sh before retrying, because an edit may have been committed"
fi

AAB_PATH="$(tr -d '\r\n' < "$ROOT/play-console-upload/LATEST_AAB.txt")"
[[ -f "$AAB_PATH" ]] || die "uploaded AAB not found at $AAB_PATH"
AAB_SHA256="$(sha256sum "$AAB_PATH" | awk '{print $1}')"
AAB_BYTES="$(stat -c '%s' "$AAB_PATH")"
cp -p -- "$AAB_PATH" "$ARTIFACT_DIR/"
cp -p -- "$AAB_PATH.sha256" "$ARTIFACT_DIR/" 2>/dev/null || true

# ---------------------------------------------------------------- readback ---
log "independent readback of version code $BUILD_NUMBER"
READBACK_PATH="$ARTIFACT_DIR/play-readback.json"
if ! scripts/ci/play-readback.sh "$BUILD_NUMBER" "$AAB_SHA256" >"$READBACK_PATH" 2>"$ARTIFACT_DIR/play-readback.log"; then
  cat "$ARTIFACT_DIR/play-readback.log" >&2 || true
  echo "[release-play] DO NOT upload again: the Play edit may already be committed." >&2
  echo "[release-play] Run scripts/ci/play-status.sh --pretty and reconcile the exact" >&2
  echo "[release-play] version/hash before deciding anything." >&2
  exit 1
fi
if ! python3 - "$READBACK_PATH" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
if not data.get("found") or data.get("conflict"):
    sys.exit(f"readback did not confirm publication: {data}")
PY
then
  echo "[release-play] DO NOT upload again: the Play edit may already be committed." >&2
  echo "[release-play] Run scripts/ci/play-status.sh --pretty and reconcile first." >&2
  exit 1
fi
log "readback confirmed version code $BUILD_NUMBER with AAB $AAB_SHA256"

# ---------------------------------------------------------------- evidence ---
PUBLICATION_EDIT="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8")).get("publicationEditId", ""))' "$RECEIPT" 2>/dev/null || true)"
LOCK_SHA256="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
FLUTTER_VERSION="$("${FLUTTER_BIN:-flutter}" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)"
GATE_STATE="skipped"; [[ "$RUN_GATE" -eq 1 ]] && GATE_STATE="passed"
DEVICE_GATE_STATE="skipped"; [[ "$RUN_DEVICE_GATE" -eq 1 ]] && DEVICE_GATE_STATE="passed"

ARCHIVED_AAB="$ARTIFACT_DIR/$(basename "$AAB_PATH")"
export VERSION BUILD_NUMBER COMMIT DIRTY TRACK RELEASE_STATUS FLUTTER_VERSION \
  LOCK_SHA256 GATE_STATE DEVICE_GATE_STATE ARCHIVED_AAB AAB_SHA256 AAB_BYTES \
  RECEIPT PUBLICATION_EDIT READBACK_PATH GATE_DIR ARTIFACT_DIR
python3 - <<'PY'
import datetime, json, os

def load(path):
    try:
        with open(path, encoding="utf-8") as source:
            return json.load(source)
    except (OSError, json.JSONDecodeError):
        return None

evidence = {
    "version": os.environ["VERSION"],
    "build_number": os.environ["BUILD_NUMBER"],
    "commit": os.environ["COMMIT"],
    "working_tree_dirty": os.environ["DIRTY"] == "1",
    "flutter_version": os.environ["FLUTTER_VERSION"],
    "lock_sha256": os.environ["LOCK_SHA256"],
    "destination": {"track": os.environ["TRACK"], "release_status": os.environ["RELEASE_STATUS"]},
    "gates": {
        "shared_offline_gate": os.environ["GATE_STATE"],
        "device_gate": os.environ["DEVICE_GATE_STATE"],
    },
    "artifact": {
        "path": os.environ["ARCHIVED_AAB"],
        "bytes": int(os.environ["AAB_BYTES"]),
        "sha256": os.environ["AAB_SHA256"],
    },
    "play": {
        "publication_edit": os.environ["PUBLICATION_EDIT"],
        "receipt": os.environ["RECEIPT"],
        "readback": load(os.environ["READBACK_PATH"]),
    },
    "qualification_limits": [
        "Google review status, storefront propagation and end-user availability are not observed",
        "device gate results are container/emulator evidence unless a physical device was used",
        "records for other lanes are not produced or revalidated by this operation",
    ],
    "timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}
path = os.path.join(os.environ["ARTIFACT_DIR"], "release-play-evidence.json")
with open(path, "w", encoding="utf-8") as target:
    json.dump(evidence, target, indent=2, sort_keys=True)
    target.write("\n")
print(path)
PY

cat >"$ARTIFACT_DIR/PLAY_RECORD_STUB.md" <<EOF
# Google Play publication: $VERSION ($BUILD_NUMBER)

Copy these observed facts into docs/engineering/release/PLAY_$VERSION.md and
fill in the changelog, qualification and limits prose.

- Package: ${PLAY_PACKAGE_NAME:-com.trebuchetdynamics.fractal.forge}
- Track / status: $TRACK / $RELEASE_STATUS
- Play edit: ${PUBLICATION_EDIT:-<read the receipt>}
- Release source: \`${COMMIT:0:8}\`$([[ "$DIRTY" -eq 1 ]] && echo ' (working tree was dirty)')
- AAB: $AAB_BYTES bytes, SHA-256 \`$AAB_SHA256\`
- Readback: $(cat "$READBACK_PATH")
- Shared offline gate: $GATE_STATE
- Device gate: $DEVICE_GATE_STATE
- Evidence: \`$ARTIFACT_DIR/release-play-evidence.json\`
EOF

log "Play $VERSION ($BUILD_NUMBER) is live on track $TRACK with status $RELEASE_STATUS"
log "AAB $AAB_SHA256 ($AAB_BYTES bytes)"
log "evidence: $ARTIFACT_DIR/release-play-evidence.json"
log "record stub: $ARTIFACT_DIR/PLAY_RECORD_STUB.md"

#!/usr/bin/env bash
# Lane-agnostic offline qualification gate.
#
# Runs the shared checks every release lane depends on, in order, without
# touching the network and without installing anything:
#
#   1. pinned-SDK identity   (fdroid/flutter.version vs `flutter --version`)
#   2. flutter pub get       (--offline --enforce-lockfile)
#   3. lockfile integrity    (sha256 before/after must match)
#   4. cargo fmt/clippy/test (locked/offline, clippy denies warnings)
#   5. flutter analyze       (--no-pub)
#   6. flutter test          (--no-pub)
#   7. python unit tests     (test/research test/scripts)
#   8. bats script tests     (test/scripts/*.bats)
#
# Usage: scripts/ci/offline-gate.sh [options]
#   --json                   print the machine summary as one JSON line
#   --log-dir DIR            stage logs and summary output (default: private mkdtemp)
#   --flutter-bin BIN        Flutter executable (default: $FLUTTER_BIN or flutter)
#   --python-bin BIN         Python with pytest (default: $PYTHON_BIN or /usr/bin/python3)
#   --bats-bin BIN           Bats executable (default: $BATS_BIN or bats)
#   --stage-timeout SECONDS  per-stage timeout (default: 3600)
#   --allow-sdk-mismatch     record an SDK mismatch as a warning instead of failing
#   --skip-analyze | --skip-tests | --skip-python | --skip-bats
#   --help
#
# Exit codes: 0 every selected stage passed, 1 a stage failed, 2 setup refused.
# The summary is always written to <log-dir>/offline-gate.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
PYTHON_BIN="${PYTHON_BIN:-/usr/bin/python3}"
BATS_BIN="${BATS_BIN:-bats}"
STAGE_TIMEOUT="${STAGE_TIMEOUT:-3600}"
JSON=0
ALLOW_SDK_MISMATCH=0
LOG_DIR=""
RUN_ANALYZE=1
RUN_TESTS=1
RUN_PYTHON=1
RUN_BATS=1

STAGE_NAMES=()
STAGE_EXITS=()
STAGE_SECONDS=()
FAILED_STAGE=""
VERDICT="passed"

log() { echo "[offline-gate] $*" >&2; }
die() { echo "[offline-gate] ERROR: $*" >&2; exit 2; }

usage() {
  sed -n '2,31p' "$SCRIPT_DIR/$(basename "$0")" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=1; shift ;;
    --allow-sdk-mismatch) ALLOW_SDK_MISMATCH=1; shift ;;
    --log-dir) [[ $# -ge 2 ]] || die "--log-dir requires a value"; LOG_DIR="$2"; shift 2 ;;
    --log-dir=*) LOG_DIR="${1#*=}"; shift ;;
    --flutter-bin) [[ $# -ge 2 ]] || die "--flutter-bin requires a value"; FLUTTER_BIN="$2"; shift 2 ;;
    --flutter-bin=*) FLUTTER_BIN="${1#*=}"; shift ;;
    --python-bin) [[ $# -ge 2 ]] || die "--python-bin requires a value"; PYTHON_BIN="$2"; shift 2 ;;
    --python-bin=*) PYTHON_BIN="${1#*=}"; shift ;;
    --bats-bin) [[ $# -ge 2 ]] || die "--bats-bin requires a value"; BATS_BIN="$2"; shift 2 ;;
    --bats-bin=*) BATS_BIN="${1#*=}"; shift ;;
    --stage-timeout) [[ $# -ge 2 ]] || die "--stage-timeout requires a value"; STAGE_TIMEOUT="$2"; shift 2 ;;
    --stage-timeout=*) STAGE_TIMEOUT="${1#*=}"; shift ;;
    --skip-analyze) RUN_ANALYZE=0; shift ;;
    --skip-tests) RUN_TESTS=0; shift ;;
    --skip-python) RUN_PYTHON=0; shift ;;
    --skip-bats) RUN_BATS=0; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ "$STAGE_TIMEOUT" =~ ^[0-9]+$ ]] || die "--stage-timeout must be an integer"
[[ -f "$ROOT/pubspec.yaml" ]] || die "pubspec.yaml not found; run from the repository checkout"
[[ -f "$ROOT/pubspec.lock" ]] || die "pubspec.lock not found; the offline gate requires the committed lockfile"
[[ -f "$ROOT/rust/Cargo.lock" ]] || die "rust/Cargo.lock not found; the offline gate requires the committed Rust lockfile"

if [[ -z "$LOG_DIR" ]]; then
  LOG_DIR="$(mktemp -d "${TMPDIR:-/tmp}/offline-gate-XXXXXX")"
else
  mkdir -p "$LOG_DIR"
fi
LOG_DIR="$(cd "$LOG_DIR" && pwd)"
if [[ "$LOG_DIR" == "$ROOT" || "$LOG_DIR" == "$ROOT"/* ]]; then
  die "log directory must live outside the checkout: $LOG_DIR"
fi
if [[ -n "${TMPDIR:-}" && ! -d "$TMPDIR" ]]; then
  die "TMPDIR is set but does not exist: $TMPDIR"
fi

command -v timeout >/dev/null 2>&1 || die "timeout unavailable; cannot bound stage runtime"
command -v sha256sum >/dev/null 2>&1 || die "sha256sum unavailable"

PINNED_VERSION=""
[[ -f "$ROOT/fdroid/flutter.version" ]] && PINNED_VERSION="$(tr -d '[:space:]' < "$ROOT/fdroid/flutter.version")"

OBSERVED_VERSION="$("$FLUTTER_BIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)"
[[ -n "$OBSERVED_VERSION" ]] || die "could not read a version from $FLUTTER_BIN --version"
if [[ -n "$PINNED_VERSION" && "$OBSERVED_VERSION" != "$PINNED_VERSION" ]]; then
  if [[ "$ALLOW_SDK_MISMATCH" -eq 1 ]]; then
    log "WARNING: Flutter $OBSERVED_VERSION does not match pinned $PINNED_VERSION"
  else
    die "Flutter $OBSERVED_VERSION does not match pinned $PINNED_VERSION (fdroid/flutter.version)"
  fi
fi

LOCK_SHA_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
RUST_LOCK_SHA_BEFORE="$(sha256sum "$ROOT/rust/Cargo.lock" | awk '{print $1}')"

finish() {
  local lock_after rust_lock_after
  lock_after="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  rust_lock_after="$(sha256sum "$ROOT/rust/Cargo.lock" | awk '{print $1}')"
  if [[ "$lock_after" != "$LOCK_SHA_BEFORE" || "$rust_lock_after" != "$RUST_LOCK_SHA_BEFORE" ]]; then
    VERDICT="failed"
    if [[ -z "$FAILED_STAGE" ]]; then
      FAILED_STAGE="lockfile"
      log "pubspec.lock or rust/Cargo.lock changed during the gate"
    fi
  fi
  STAGE_NAMES_JOINED="$(printf '%s\n' "${STAGE_NAMES[@]}")" \
  STAGE_EXITS_JOINED="$(printf '%s\n' "${STAGE_EXITS[@]}")" \
  STAGE_SECONDS_JOINED="$(printf '%s\n' "${STAGE_SECONDS[@]}")" \
  OBSERVED="$OBSERVED_VERSION" PINNED="$PINNED_VERSION" \
  LOCK_BEFORE="$LOCK_SHA_BEFORE" LOCK_AFTER="$lock_after" \
  RUST_LOCK_BEFORE="$RUST_LOCK_SHA_BEFORE" RUST_LOCK_AFTER="$rust_lock_after" \
  VERDICT="$VERDICT" FAILED="$FAILED_STAGE" LOG_DIR="$LOG_DIR" \
    python3 - <<'PY'
import json, os

names = [item for item in os.environ["STAGE_NAMES_JOINED"].splitlines() if item]
exits = [item for item in os.environ["STAGE_EXITS_JOINED"].splitlines() if item]
seconds = [item for item in os.environ["STAGE_SECONDS_JOINED"].splitlines() if item]
payload = {
    "verdict": os.environ["VERDICT"],
    "failed_stage": os.environ["FAILED"] or None,
    "flutter_version": os.environ["OBSERVED"],
    "pinned_flutter_version": os.environ["PINNED"] or None,
    "lock_sha256_before": os.environ["LOCK_BEFORE"],
    "lock_sha256_after": os.environ["LOCK_AFTER"],
    "lock_unchanged": os.environ["LOCK_BEFORE"] == os.environ["LOCK_AFTER"],
    "rust_lock_sha256_before": os.environ["RUST_LOCK_BEFORE"],
    "rust_lock_sha256_after": os.environ["RUST_LOCK_AFTER"],
    "rust_lock_unchanged": os.environ["RUST_LOCK_BEFORE"] == os.environ["RUST_LOCK_AFTER"],
    "log_dir": os.environ["LOG_DIR"],
    "stages": [
        {"stage": name, "exit_code": int(code), "seconds": float(elapsed)}
        for name, code, elapsed in zip(names, exits, seconds)
    ],
}
print(json.dumps(payload, sort_keys=True))
PY
}

run_stage() {
  local name="$1"
  shift
  local log_file="$LOG_DIR/$name.log" started=$SECONDS status=0
  log "running $name: $*"
  if timeout --kill-after=10 "$STAGE_TIMEOUT" "$@" >"$log_file" 2>&1; then
    status=0
  else
    status=$?
  fi
  STAGE_NAMES+=("$name")
  STAGE_EXITS+=("$status")
  STAGE_SECONDS+=("$((SECONDS - started))")
  if [[ "$status" -ne 0 ]]; then
    FAILED_STAGE="$name"
    VERDICT="failed"
    log "stage $name failed with exit $status (log: $log_file)"
    tail -n 40 "$log_file" >&2 || true
    return "$status"
  fi
  log "stage $name passed in $((SECONDS - started))s"
}

finish_and_exit() {
  local status="${1:-1}" summary_line
  summary_line="$(finish)"
  printf '%s\n' "$summary_line" >"$LOG_DIR/offline-gate.json"
  if [[ "$JSON" -eq 1 ]]; then
    printf '%s\n' "$summary_line"
  else
    log "summary: $LOG_DIR/offline-gate.json"
  fi
  if [[ "$status" -eq 0 && "$summary_line" == *'"verdict": "failed"'* ]]; then
    status=1
  fi
  exit "$status"
}

run_stage_or_stop() {
  if ! run_stage "$@"; then
    finish_and_exit 1
  fi
}

run_stage_or_stop flutter-pub-get "$FLUTTER_BIN" pub get --offline --enforce-lockfile

# Dependency preparation is the only network-free resolution step. Any lockfile
# change here is a metadata violation, so check it before the remaining stages.
if [[ "$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')" != "$LOCK_SHA_BEFORE" ||
      "$(sha256sum "$ROOT/rust/Cargo.lock" | awk '{print $1}')" != "$RUST_LOCK_SHA_BEFORE" ]]; then
  FAILED_STAGE="lockfile"
  VERDICT="failed"
  log "pubspec.lock or rust/Cargo.lock changed during dependency preparation"
  finish_and_exit 1
fi

# Provision Cargo/toolchain/cache separately. Missing tools fail the stage.
run_stage_or_stop cargo-fmt cargo fmt --manifest-path rust/Cargo.toml --all -- --check
run_stage_or_stop cargo-clippy cargo clippy --manifest-path rust/Cargo.toml --workspace --all-targets --locked --offline -- -D warnings
run_stage_or_stop cargo-test cargo test --manifest-path rust/Cargo.toml --workspace --locked --offline
if [[ "$(sha256sum "$ROOT/rust/Cargo.lock" | awk '{print $1}')" != "$RUST_LOCK_SHA_BEFORE" ]]; then
  FAILED_STAGE="lockfile"
  VERDICT="failed"
  log "rust/Cargo.lock changed during Cargo checks"
  finish_and_exit 1
fi

if [[ "$RUN_ANALYZE" -eq 1 ]]; then
  run_stage_or_stop flutter-analyze "$FLUTTER_BIN" analyze --no-pub
fi
if [[ "$RUN_TESTS" -eq 1 ]]; then
  run_stage_or_stop flutter-tests "$FLUTTER_BIN" test --no-pub
fi
if [[ "$RUN_PYTHON" -eq 1 ]]; then
  run_stage_or_stop python-tests "$PYTHON_BIN" -m pytest test/research test/scripts -q
fi
if [[ "$RUN_BATS" -eq 1 ]]; then
  shopt -s nullglob
  bats_files=(test/scripts/*.bats)
  shopt -u nullglob
  if [[ ${#bats_files[@]} -eq 0 ]]; then
    FAILED_STAGE="bats"
    VERDICT="failed"
    log "no bats files found under test/scripts"
    finish_and_exit 1
  fi
  run_stage_or_stop bats-tests "$BATS_BIN" "${bats_files[@]}"
fi

finish_and_exit 0

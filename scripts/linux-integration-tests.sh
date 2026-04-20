#!/usr/bin/env bash
set -euo pipefail

# Run Flutter Linux integration tests one file at a time.
#
# Why: `flutter test file_a file_b -d linux` is flaky on Linux desktop in this
# repo. After the first file, the desktop runner can fail to reattach with:
#   "Error waiting for a debug connection: The log reader stopped unexpectedly"
#
# Running each integration target in its own Flutter invocation is reliable.
#
# Usage:
#   scripts/linux-integration-tests.sh
#   scripts/linux-integration-tests.sh integration_test/app_test.dart
#   KEEP_GOING=1 scripts/linux-integration-tests.sh integration_test/*.dart

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export PATH="$HOME/.local/bin:$HOME/flutter/bin:$PATH"

DEVICE_ID="${DEVICE_ID:-linux}"
REPORTER="${REPORTER:-expanded}"
KEEP_GOING="${KEEP_GOING:-0}"
INCLUDE_EMULATOR_TESTS="${INCLUDE_EMULATOR_TESTS:-0}"
XVFB_SCREEN="${XVFB_SCREEN:-1280x1024x24}"

log() {
  echo "[linux-integration] $*"
}

run_flutter_test() {
  local test_file="$1"

  if command -v xvfb-run >/dev/null 2>&1 && [[ -z "${DISPLAY:-}" ]]; then
    xvfb-run -a -s "-screen 0 ${XVFB_SCREEN}" \
      flutter test "$test_file" -d "$DEVICE_ID" --reporter "$REPORTER"
  else
    flutter test "$test_file" -d "$DEVICE_ID" --reporter "$REPORTER"
  fi
}

discover_tests() {
  find integration_test -maxdepth 1 -name '*_test.dart' -print | sort
}

declare -a tests

if [[ "$#" -gt 0 ]]; then
  tests=("$@")
else
  while IFS= read -r file; do
    if [[ "$INCLUDE_EMULATOR_TESTS" != "1" && "$(basename "$file")" == emulator_* ]]; then
      continue
    fi
    tests+=("$file")
  done < <(discover_tests)
fi

if [[ "${#tests[@]}" -eq 0 ]]; then
  log "ERROR: no integration tests selected"
  exit 1
fi

declare -a failures=()

for test_file in "${tests[@]}"; do
  log ">>> $test_file"
  if run_flutter_test "$test_file"; then
    log "PASS $test_file"
  else
    log "FAIL $test_file"
    failures+=("$test_file")
    if [[ "$KEEP_GOING" != "1" ]]; then
      break
    fi
  fi
done

if [[ "${#failures[@]}" -gt 0 ]]; then
  log "Failed files:"
  for test_file in "${failures[@]}"; do
    log "  - $test_file"
  done
  exit 1
fi

log "All selected Linux integration tests passed."

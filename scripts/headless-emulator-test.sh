#!/usr/bin/env bash
set -euo pipefail

# Headless Android emulator runner for integration tests.
#
# What it does:
# - Reuse an existing running emulator if available (default).
# - Otherwise start an AVD in headless mode (-no-window).
# - Wait for boot completion.
# - Disable system animations for deterministic UI timing.
# - Run a Flutter integration test target on that device.
# - Capture screenshot + logcat to a timestamped log directory.
# - If this script started the emulator, it will stop it on exit (default).
#
# Usage:
#   scripts/headless-emulator-test.sh
#   scripts/headless-emulator-test.sh flutter test integration_test/ -d "$DEVICE"
#
# Env vars:
#   AVD_NAME=fractal_test            Which AVD to start when needed
#   REUSE_EXISTING=1                 Reuse an already-running emulator (default 1)
#   START_EMULATOR=1                 Allow starting emulator if none running (default 1)
#   HEADLESS=1                       Use -no-window (default 1)
#   GPU_MODE=swiftshader_indirect    Emulator GPU mode (default swiftshader_indirect)
#   WIPE_DATA=0                      Start with -wipe-data (default 0)
#   PORT=auto                        Emulator port (default auto)
#   KEEP_EMULATOR=0                  Keep emulator running even if started here (default 0)
#   TEST_TARGET=integration_test/app_test.dart   Default test target when no args
#   REPORTER=expanded                Flutter test reporter (default expanded)
#   ENABLE_GPU_ON_EMULATOR=0         Add dart define to bypass emulator CPU guard
#   LOG_DIR=agent_test_logs/headless Output dir for artifacts (default under repo)
#   BOOT_TIMEOUT_SECS=240            Boot wait timeout (default 240)
#   TEST_TIMEOUT_SECS=900            Test timeout (default 900)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/usr/lib/android-sdk}"
export PATH="$HOME/.local/bin:$HOME/flutter/bin:$PATH"

AVD_NAME="${AVD_NAME:-fractal_test}"
REUSE_EXISTING="${REUSE_EXISTING:-1}"
START_EMULATOR="${START_EMULATOR:-1}"
HEADLESS="${HEADLESS:-1}"
GPU_MODE="${GPU_MODE:-swiftshader_indirect}"
WIPE_DATA="${WIPE_DATA:-0}"
PORT="${PORT:-auto}"
KEEP_EMULATOR="${KEEP_EMULATOR:-0}"
TEST_TARGET="${TEST_TARGET:-integration_test/app_test.dart}"
REPORTER="${REPORTER:-expanded}"
ENABLE_GPU_ON_EMULATOR="${ENABLE_GPU_ON_EMULATOR:-0}"
LOG_DIR="${LOG_DIR:-$ROOT/agent_test_logs/headless}"
BOOT_TIMEOUT_SECS="${BOOT_TIMEOUT_SECS:-240}"
TEST_TIMEOUT_SECS="${TEST_TIMEOUT_SECS:-900}"

mkdir -p "$LOG_DIR"

log() { echo "[headless] $*"; }
die() { echo "[headless] ERROR: $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

require_cmd adb
require_cmd flutter

EMULATOR_BIN="${EMULATOR_BIN:-$ANDROID_SDK_ROOT/emulator/emulator}"
[ -x "$EMULATOR_BIN" ] || die "Emulator binary not found/executable: $EMULATOR_BIN"

adb start-server >/dev/null 2>&1 || true

started_emulator=0
emu_pid=""
DEVICE="${DEVICE:-}"

list_emulators() {
  adb devices | awk '$2=="device" && $1 ~ /^emulator-/ {print $1}'
}

pick_free_port() {
  # Emulator uses even ports: 5554, 5556, ...
  local used ports p
  used="$(list_emulators | sed 's/^emulator-//' || true)"
  for p in 5554 5556 5558 5560 5562 5564 5566 5568 5570 5572; do
    if ! echo "$used" | tr ' ' '\n' | grep -qx "$p"; then
      echo "$p"
      return 0
    fi
  done
  # Fall back to a reasonable default; emulator will pick if this is busy.
  echo "5554"
}

cleanup() {
  if [ "$KEEP_EMULATOR" = "1" ]; then
    return 0
  fi

  if [ "$started_emulator" = "1" ]; then
    log "Stopping emulator..."
    if [ -n "${DEVICE:-}" ]; then
      adb -s "$DEVICE" emu kill >/dev/null 2>&1 || true
    fi
    if [ -n "${emu_pid:-}" ]; then
      kill "$emu_pid" >/dev/null 2>&1 || true
    fi
  fi
}
trap cleanup EXIT

TS="$(date +%Y%m%d_%H%M%S)"

if [ -z "${DEVICE:-}" ] && [ "$REUSE_EXISTING" = "1" ]; then
  existing="$(list_emulators | head -n 1 || true)"
  if [ -n "$existing" ]; then
    DEVICE="$existing"
    log "Reusing running emulator: $DEVICE"
  fi
fi

if [ -z "${DEVICE:-}" ]; then
  if [ "$START_EMULATOR" != "1" ]; then
    die "No emulator found and START_EMULATOR=0"
  fi

  if [ "$PORT" = "auto" ]; then
    PORT="$(pick_free_port)"
  fi
  DEVICE="emulator-$PORT"

  log "Starting emulator AVD=$AVD_NAME device=$DEVICE headless=$HEADLESS gpu=$GPU_MODE"

  args=(-avd "$AVD_NAME" -no-audio -no-boot-anim -gpu "$GPU_MODE" -netdelay none -netspeed full -accel auto)
  if [ "$HEADLESS" = "1" ]; then
    args+=(-no-window)
  fi
  if [ "$WIPE_DATA" = "1" ]; then
    args+=(-wipe-data)
  fi
  # Make device serial deterministic.
  args+=(-port "$PORT")

  emu_log="$LOG_DIR/emulator_${TS}.log"
  "$EMULATOR_BIN" "${args[@]}" >"$emu_log" 2>&1 &
  emu_pid="$!"
  started_emulator=1

  log "Emulator PID=$emu_pid (log: $emu_log)"
fi

log "Waiting for device: $DEVICE"
adb -s "$DEVICE" wait-for-device

log "Waiting for boot completion (timeout ${BOOT_TIMEOUT_SECS}s)..."
boot_deadline=$(( $(date +%s) + BOOT_TIMEOUT_SECS ))
while true; do
  v="$(adb -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  if [ "$v" = "1" ]; then
    break
  fi
  if [ "$(date +%s)" -ge "$boot_deadline" ]; then
    die "Timed out waiting for sys.boot_completed=1 (device=$DEVICE)"
  fi
  sleep 3
done

# Stabilize UI timing.
adb -s "$DEVICE" shell settings put global window_animation_scale 0 >/dev/null 2>&1 || true
adb -s "$DEVICE" shell settings put global transition_animation_scale 0 >/dev/null 2>&1 || true
adb -s "$DEVICE" shell settings put global animator_duration_scale 0 >/dev/null 2>&1 || true

# Wake/unlock.
adb -s "$DEVICE" shell input keyevent 82 >/dev/null 2>&1 || true

adb -s "$DEVICE" logcat -c >/dev/null 2>&1 || true

run_cmd=()
if [ "$#" -gt 0 ]; then
  run_cmd=("$@")
else
  run_cmd=(flutter test "$TEST_TARGET" -d "$DEVICE" --reporter "$REPORTER")
fi

if [ "$ENABLE_GPU_ON_EMULATOR" = "1" ] && [ "${run_cmd[0]:-}" = "flutter" ]; then
  has_gpu_define=0
  for arg in "${run_cmd[@]}"; do
    if [ "$arg" = "--dart-define=ALLOW_GPU_ON_ANDROID_EMULATOR=true" ] || \
       [ "$arg" = "--dart-define=SKIP_EMULATOR_GUARD=true" ]; then
      has_gpu_define=1
      break
    fi
  done
  if [ "$has_gpu_define" = "0" ]; then
    run_cmd+=("--dart-define=ALLOW_GPU_ON_ANDROID_EMULATOR=true")
  fi
  log "GPU emulator mode enabled (bypass emulator CPU guard)"
fi

export DEVICE

test_log="$LOG_DIR/test_${TS}.log"
log "Running: ${run_cmd[*]}"

set +e
timeout "${TEST_TIMEOUT_SECS}s" "${run_cmd[@]}" 2>&1 | tee "$test_log"
rc=${PIPESTATUS[0]}
set -e

log "Capturing screenshot + logcat..."
adb -s "$DEVICE" shell screencap -p /sdcard/headless_screen.png >/dev/null 2>&1 || true
adb -s "$DEVICE" pull /sdcard/headless_screen.png "$LOG_DIR/screen_${TS}.png" >/dev/null 2>&1 || true
adb -s "$DEVICE" shell rm /sdcard/headless_screen.png >/dev/null 2>&1 || true
adb -s "$DEVICE" logcat -d -v time > "$LOG_DIR/logcat_${TS}.log" 2>&1 || true

{
  echo "TS=$TS"
  echo "DEVICE=$DEVICE"
  echo "STARTED_EMULATOR=$started_emulator"
  echo "RC=$rc"
  echo "TEST_LOG=$test_log"
} > "$LOG_DIR/summary_${TS}.txt"

log "Done (rc=$rc). Artifacts: $LOG_DIR"
exit "$rc"

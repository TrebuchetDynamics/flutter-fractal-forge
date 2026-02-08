#!/usr/bin/env bash
set -euo pipefail

# Overnight automated emulator test loop for flutter-fractal-forge.
# - Builds debug APK
# - Installs to connected emulator
# - Runs integration tests
# - Captures screenshot + logcat
# - Repeats forever (or until killed)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export PATH="$HOME/flutter/bin:$PATH"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/usr/lib/android-sdk}"
export GIT_PAGER=cat

DEVICE="${DEVICE:-emulator-5554}"
LOG_DIR="${LOG_DIR:-$ROOT/agent_test_logs}"
LOCK_FILE="${LOCK_FILE:-$ROOT/.android_flutter_build.lock}"
mkdir -p "$LOG_DIR"
touch "$LOCK_FILE"

# Run a command under a cross-process lock.
# This prevents concurrent Flutter/Gradle Android builds from corrupting intermediates
# (e.g. intermittent missing build/app/intermediates/.../flutter_assets/kernel_blob.bin.jar).
with_build_lock() {
  # Note: flock releases automatically when the command exits.
  flock "$LOCK_FILE" "$@"
}

flutter_build_apk_debug() {
  local log_file="$1"
  local attempt

  local last_rc=1
  for attempt in 1 2; do
    echo "[BUILD] debug apk (attempt $attempt)"

    # Guard against Gradle/Flutter hangs.
    if with_build_lock timeout 12m flutter build apk --debug 2>&1 | tee -a "$log_file"; then
      return 0
    fi

    last_rc=$?

    echo "[BUILD] failed (attempt $attempt, rc=$last_rc); cleaning + retrying..." | tee -a "$log_file"

    # Cleanup under the same lock so we don't delete intermediates while another build is running.
    with_build_lock flutter clean >>"$log_file" 2>&1 || true
    (cd "$ROOT/android" && with_build_lock ./gradlew --stop >>"$log_file" 2>&1) || true
    sleep 5
  done

  return "$last_rc"
}

flutter_test_integration() {
  local log_file="$1"
  local attempt

  local last_rc=1
  for attempt in 1 2; do
    echo "[TEST] integration_test/app_test.dart (attempt $attempt)" | tee -a "$log_file"

    # `flutter test ... -d <device>` triggers an Android build/install. Serialize it too.
    if with_build_lock timeout 12m flutter test integration_test/app_test.dart -d "$DEVICE" --reporter expanded \
      2>&1 | tee -a "$log_file"; then
      return 0
    fi

    last_rc=$?

    echo "[TEST] failed (attempt $attempt, rc=$last_rc); cleaning + retrying..." | tee -a "$log_file"
    with_build_lock flutter clean >>"$log_file" 2>&1 || true
    (cd "$ROOT/android" && with_build_lock ./gradlew --stop >>"$log_file" 2>&1) || true
    sleep 5
  done

  return "$last_rc"
}

ITER=0

echo "[loop] root=$ROOT"
echo "[loop] device=$DEVICE"
echo "[loop] log_dir=$LOG_DIR"
echo "[loop] lock_file=$LOCK_FILE"
flutter --version | sed 's/^/[flutter] /'

adb wait-for-device

while true; do
  ITER=$((ITER+1))
  TS="$(date +%Y%m%d_%H%M%S)"
  echo "====================================================="
  echo "ITERATION $ITER @ $TS"
  echo "====================================================="

  BUILD_LOG="$LOG_DIR/build_${ITER}_${TS}.log"
  TEST_LOG="$LOG_DIR/test_${ITER}_${TS}.log"

  # Clean device logs for this iteration.
  adb logcat -c || true

  if ! flutter_build_apk_debug "$BUILD_LOG"; then
    echo "BUILD_FAIL" | tee "$LOG_DIR/summary_${ITER}_${TS}.txt"
    sleep 10
    continue
  fi

  APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
  if [ ! -f "$APK" ]; then
    echo "BUILD_FAIL: missing $APK" | tee "$LOG_DIR/summary_${ITER}_${TS}.txt"
    sleep 10
    continue
  fi

  echo "[INSTALL] $APK"
  adb -s "$DEVICE" install -r "$APK" 2>&1 | tee "$LOG_DIR/install_${ITER}_${TS}.log" || true

  TEST_EXIT=0
  if flutter_test_integration "$TEST_LOG"; then
    TEST_EXIT=0
  else
    TEST_EXIT=$?
  fi

  echo "[SCREENSHOT]"
  adb -s "$DEVICE" shell screencap -p /sdcard/screen_${ITER}.png >/dev/null 2>&1 || true
  adb -s "$DEVICE" pull /sdcard/screen_${ITER}.png "$LOG_DIR/screen_${ITER}_${TS}.png" >/dev/null 2>&1 || true

  echo "[LOGCAT] dump"
  adb -s "$DEVICE" logcat -d -v time > "$LOG_DIR/logcat_${ITER}_${TS}.log" 2>&1 || true

  # Heuristic crash detection.
  CRASH_HITS=$(grep -E "FATAL EXCEPTION|SIGSEGV|flutter\]: \[ERROR\]" -n "$LOG_DIR/logcat_${ITER}_${TS}.log" | head -n 20 || true)

  {
    echo "ITER=$ITER"
    echo "TS=$TS"
    echo "TEST_EXIT=$TEST_EXIT"
    if [ -n "$CRASH_HITS" ]; then
      echo "CRASH=1"
      echo "CRASH_SNIPPET:"
      echo "$CRASH_HITS"
    else
      echo "CRASH=0"
    fi
  } | tee "$LOG_DIR/summary_${ITER}_${TS}.txt"

  # Slow down a bit; keep device stable.
  sleep 15

done

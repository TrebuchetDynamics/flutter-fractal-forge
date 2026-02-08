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
mkdir -p "$LOG_DIR"

ITER=0

echo "[loop] root=$ROOT"
echo "[loop] device=$DEVICE"
echo "[loop] log_dir=$LOG_DIR"
flutter --version | sed 's/^/[flutter] /'

adb wait-for-device

while true; do
  ITER=$((ITER+1))
  TS="$(date +%Y%m%d_%H%M%S)"
  echo "====================================================="
  echo "ITERATION $ITER @ $TS"
  echo "====================================================="

  # Clean device logs for this iteration.
  adb logcat -c || true

  echo "[BUILD] debug apk"
  if ! flutter build apk --debug 2>&1 | tee "$LOG_DIR/build_${ITER}_${TS}.log"; then
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

  echo "[TEST] integration_test/app_test.dart"
  TEST_EXIT=0
  flutter test integration_test/app_test.dart -d "$DEVICE" --reporter expanded \
    2>&1 | tee "$LOG_DIR/test_${ITER}_${TS}.log" || TEST_EXIT=$?

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

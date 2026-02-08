#!/usr/bin/env bash
set -euo pipefail

# Overnight UI monkey loop for Flutter Fractal Forge.
# This complements integration_test by adding randomized UI events to reproduce crashes.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export PATH="$HOME/flutter/bin:$PATH"

DEVICE="${DEVICE:-emulator-5554}"
PKG="${PKG:-com.fractals.flutter_fractals}"
ACT="${ACT:-com.fractals.flutter_fractals/.MainActivity}"
LOG_DIR="${LOG_DIR:-$ROOT/agent_ui_logs}"
LOCK_FILE="${LOCK_FILE:-$ROOT/.android_flutter_build.lock}"
EVENTS="${EVENTS:-1200}"
SEED="${SEED:-42}"
mkdir -p "$LOG_DIR"
touch "$LOCK_FILE"

# Run a command under a cross-process lock.
# Prevents concurrent Flutter/Gradle Android builds from corrupting intermediates.
with_build_lock() {
  flock "$LOCK_FILE" "$@"
}

flutter_build_apk_debug() {
  local log_file="$1"
  local attempt

  local last_rc=1
  for attempt in 1 2; do
    echo "[BUILD] debug apk (attempt $attempt)" | tee -a "$log_file"

    if with_build_lock timeout 12m flutter build apk --debug 2>&1 | tee -a "$log_file"; then
      return 0
    fi

    last_rc=$?

    echo "[BUILD] failed (attempt $attempt, rc=$last_rc); cleaning + retrying..." | tee -a "$log_file"
    with_build_lock flutter clean >>"$log_file" 2>&1 || true
    (cd "$ROOT/android" && with_build_lock ./gradlew --stop >>"$log_file" 2>&1) || true
    sleep 5
  done

  return "$last_rc"
}

ITER=0
adb -s "$DEVICE" wait-for-device

echo "[fractal-ui] root=$ROOT"
echo "[fractal-ui] device=$DEVICE"
echo "[fractal-ui] log_dir=$LOG_DIR"
echo "[fractal-ui] lock_file=$LOCK_FILE"

while true; do
  ITER=$((ITER+1))
  TS="$(date +%Y%m%d_%H%M%S)"

  echo "====================================================="
  echo "[fractal-ui] ITER=$ITER TS=$TS"
  echo "====================================================="

  adb -s "$DEVICE" logcat -c || true

  BUILD_LOG="$LOG_DIR/build_${ITER}_${TS}.log"

  # Ensure debug build exists and installed.
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

  adb -s "$DEVICE" install -r "$APK" >/dev/null 2>&1 || true

  # Launch app.
  adb -s "$DEVICE" shell am start -n "$ACT" >/dev/null 2>&1 || true
  sleep 3

  # Random events.
  adb -s "$DEVICE" shell monkey -p "$PKG" \
    --pct-syskeys 0 \
    --throttle 30 \
    --ignore-crashes --ignore-timeouts --monitor-native-crashes \
    -s "$SEED" "$EVENTS" \
    > "$LOG_DIR/monkey_${ITER}_${TS}.log" 2>&1 || true

  # Screenshot.
  adb -s "$DEVICE" shell screencap -p /sdcard/fractal_${ITER}.png >/dev/null 2>&1 || true
  adb -s "$DEVICE" pull /sdcard/fractal_${ITER}.png "$LOG_DIR/screen_${ITER}_${TS}.png" >/dev/null 2>&1 || true

  # Logcat.
  adb -s "$DEVICE" logcat -d -v time > "$LOG_DIR/logcat_${ITER}_${TS}.log" 2>&1 || true

  CRASH=$(grep -E "FATAL EXCEPTION|ANR in|SIGSEGV|Fatal signal|JNI DETECTED ERROR" -n "$LOG_DIR/logcat_${ITER}_${TS}.log" | head -n 40 || true)

  {
    echo "ITER=$ITER"
    echo "TS=$TS"
    if [ -n "$CRASH" ]; then
      echo "CRASH=1"
      echo "CRASH_SNIPPET:"
      echo "$CRASH"
    else
      echo "CRASH=0"
    fi
  } | tee "$LOG_DIR/summary_${ITER}_${TS}.txt"

  sleep 10

done

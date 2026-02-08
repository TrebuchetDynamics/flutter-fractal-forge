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
EVENTS="${EVENTS:-1200}"
SEED="${SEED:-42}"
mkdir -p "$LOG_DIR"

ITER=0
adb -s "$DEVICE" wait-for-device

while true; do
  ITER=$((ITER+1))
  TS="$(date +%Y%m%d_%H%M%S)"

  echo "====================================================="
  echo "[fractal-ui] ITER=$ITER TS=$TS"
  echo "====================================================="

  adb -s "$DEVICE" logcat -c || true

  # Ensure debug build exists and installed
  flutter build apk --debug >/dev/null
  APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
  adb -s "$DEVICE" install -r "$APK" >/dev/null 2>&1 || true

  # Launch app
  adb -s "$DEVICE" shell am start -n "$ACT" >/dev/null 2>&1 || true
  sleep 3

  # Random events
  adb -s "$DEVICE" shell monkey -p "$PKG" \
    --pct-syskeys 0 \
    --throttle 30 \
    --ignore-crashes --ignore-timeouts --monitor-native-crashes \
    -s "$SEED" "$EVENTS" \
    > "$LOG_DIR/monkey_${ITER}_${TS}.log" 2>&1 || true

  # Screenshot
  adb -s "$DEVICE" shell screencap -p /sdcard/fractal_${ITER}.png >/dev/null 2>&1 || true
  adb -s "$DEVICE" pull /sdcard/fractal_${ITER}.png "$LOG_DIR/screen_${ITER}_${TS}.png" >/dev/null 2>&1 || true

  # Logcat
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

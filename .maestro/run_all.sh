#!/usr/bin/env bash
# Run all Maestro tests sequentially with fresh app launch between each.
# Usage: bash .maestro/run_all.sh
set -e

APP_ID="com.trebuchetdynamics.fractal.forge"
ACTIVITY="$APP_ID/.MainActivity"
PASS=0
FAIL=0
RESULTS=()
FIRST_RUN=true

dismiss_anr() {
  # Dismiss ANR dialog if present (tap "Wait" button).
  local focus
  focus=$(adb shell dumpsys window 2>/dev/null | grep "mCurrentFocus" || true)
  if echo "$focus" | grep -q "Not Responding"; then
    echo "--- ANR detected, dismissing ---"
    # Tap "Wait" button (approximate center-right of ANR dialog)
    adb shell input tap 800 1500 2>/dev/null || true
    sleep 2
  fi
}

launch_app() {
  echo "--- Launching $APP_ID ---"
  adb shell am force-stop "$APP_ID" 2>/dev/null || true
  sleep 2
  adb shell am start -n "$ACTIVITY" 2>/dev/null || true

  if $FIRST_RUN; then
    # First cold start: Flutter engine + shader compilation takes 2-3 min
    # on emulators with swiftshader_indirect GPU.
    echo "--- Cold start: waiting 150s for Flutter engine + shaders ---"
    sleep 40; dismiss_anr
    sleep 40; dismiss_anr
    sleep 40; dismiss_anr
    sleep 30; dismiss_anr
    FIRST_RUN=false
  else
    # Warm start: shaders cached, app loads much faster.
    echo "--- Warm start: waiting 30s for app to stabilize ---"
    sleep 15; dismiss_anr
    sleep 15; dismiss_anr
  fi

  # Verify app is in foreground
  local focus
  focus=$(adb shell dumpsys window 2>/dev/null | grep "mCurrentFocus" || true)
  echo "--- Current focus: $focus ---"
}

for flow in .maestro/0*.yaml; do
  name=$(basename "$flow")
  echo ""
  echo "=============================="
  echo "  Running: $name"
  echo "=============================="

  launch_app

  if ~/.maestro/bin/maestro test "$flow" 2>&1; then
    echo "  PASS: $name"
    RESULTS+=("PASS  $name")
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name"
    RESULTS+=("FAIL  $name")
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "=============================="
echo "  MAESTRO TEST SUMMARY"
echo "=============================="
for r in "${RESULTS[@]}"; do
  echo "  $r"
done
echo ""
echo "  Total: $((PASS + FAIL))  Pass: $PASS  Fail: $FAIL"
echo "=============================="

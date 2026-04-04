#!/usr/bin/env bash
# Run all Maestro tests sequentially with fresh app launch between each.
# Usage: bash .maestro/run_all.sh
set -e

APP_ID="com.trebuchetdynamics.fractal.forge"
ACTIVITY="$APP_ID/.MainActivity"
# Standalone debug installs can stall on the native splash on real devices,
# while profile builds launch normally without needing the Flutter tool attached.
APK_PATH="${APK_PATH:-build/app/outputs/flutter-apk/app-profile.apk}"
PASS=0
FAIL=0
RESULTS=()
FIRST_RUN=true

wait_for_awake_screen() {
  local attempts=0
  while [ "$attempts" -lt 10 ]; do
    if adb shell dumpsys power 2>/dev/null | grep -q "mWakefulness=Awake"; then
      return 0
    fi
    attempts=$((attempts + 1))
    sleep 1
  done
  return 1
}

dismiss_play_protect() {
  local focus
  focus=$(adb shell dumpsys window 2>/dev/null | grep "mCurrentFocus" || true)
  if echo "$focus" | grep -q "PlayProtectDialogsActivity"; then
    echo "--- Play Protect dialog detected, dismissing ---"
    adb shell input tap 540 1630 2>/dev/null || true
    sleep 2
  fi
}

prepare_device() {
  echo "--- Waking and unlocking device ---"
  adb shell input keyevent KEYCODE_WAKEUP 2>/dev/null || true
  adb shell input keyevent KEYCODE_MENU 2>/dev/null || true
  adb shell wm dismiss-keyguard 2>/dev/null || true
  adb shell input swipe 540 1800 540 600 250 2>/dev/null || true
  wait_for_awake_screen || true

  echo "--- Collapsing system panels ---"
  adb shell cmd statusbar collapse 2>/dev/null || true
  adb shell input keyevent KEYCODE_BACK 2>/dev/null || true
  sleep 2
}

dismiss_anr() {
  # Dismiss ANR dialog if present (tap "Wait" button).
  local focus
  focus=$(adb shell dumpsys window 2>/dev/null | grep "mCurrentFocus" || true)
  if echo "$focus" | grep -q "Not Responding"; then
    echo "--- ANR detected, dismissing ---"
    adb shell input tap 800 1500 2>/dev/null || true
    sleep 2
  fi
}

disable_interfering_apps() {
  # Disable apps that steal focus on google_apis images.
  adb shell pm disable-user --user 0 com.arenaton.ninelives 2>/dev/null || true
  adb shell pm disable-user --user 0 com.trebuchetdynamics.melodrop 2>/dev/null || true
  adb shell am force-stop com.arenaton.ninelives 2>/dev/null || true
  adb shell am force-stop com.trebuchetdynamics.melodrop 2>/dev/null || true
}

ensure_app_installed() {
  # Reinstall APK if it was uninstalled (common after driver install).
  if ! adb shell pm list packages 2>/dev/null | grep -q "$APP_ID"; then
    echo "--- App not installed, reinstalling ---"
    adb install -r "$APK_PATH" 2>/dev/null || true
  fi

  dismiss_play_protect
}

launch_app() {
  prepare_device

  echo "--- Ensuring app is installed ---"
  ensure_app_installed

  echo "--- Launching $APP_ID ---"
  adb shell am force-stop "$APP_ID" 2>/dev/null || true
  sleep 2
  adb shell am start -n "$ACTIVITY" 2>/dev/null || true

  if $FIRST_RUN; then
    # First cold start: Flutter engine + shader compilation takes 1-2 min
    # on emulators with swiftshader_indirect GPU.
    echo "--- Cold start: waiting 90s for Flutter engine + shaders ---"
    sleep 30; dismiss_anr
    sleep 30; dismiss_anr
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

install_maestro_driver() {
  # Install Maestro driver once at the start, then use --no-reinstall-driver
  # for each test to avoid killing the app during driver reinstall.
  echo "=============================="
  echo "  Installing Maestro driver"
  echo "=============================="
  prepare_device
  disable_interfering_apps
  ensure_app_installed
  adb shell am start -n "$ACTIVITY" 2>/dev/null || true
  sleep 20
  # Run a no-op to trigger driver install, then kill it after driver is ready.
  timeout 120 ~/.maestro/bin/maestro test --format NOOP .maestro/01_app_launch.yaml 2>&1 || true
  echo "--- Driver installed ---"
}

# Step 0: Disable interfering apps and install driver once.
disable_interfering_apps
install_maestro_driver

# Re-disable interfering apps (driver install may have re-enabled them).
disable_interfering_apps

for flow in .maestro/0*.yaml; do
  name=$(basename "$flow")
  echo ""
  echo "=============================="
  echo "  Running: $name"
  echo "=============================="

  launch_app

  if ~/.maestro/bin/maestro test --no-reinstall-driver "$flow" 2>&1; then
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

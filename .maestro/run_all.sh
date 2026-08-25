#!/usr/bin/env bash
# Run all Maestro flows sequentially with a fresh app launch between each.
# Usage: bash .maestro/run_all.sh
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_ID="com.trebuchetdynamics.fractal.forge"
ACTIVITY="$APP_ID/.MainActivity"
APK_PATH="${APK_PATH:-build/app/outputs/flutter-apk/app-debug.apk}"
ADB_BIN="${ADB_BIN:-adb}"
MAESTRO_BIN="${MAESTRO_BIN:-$HOME/.maestro/bin/maestro}"
DEVICE_SERIAL="${DEVICE_SERIAL:-${1:-}}"
APP_START_TIMEOUT_SECONDS="${APP_START_TIMEOUT_SECONDS:-120}"
PASS=0
FAIL=0
RESULTS=()

if [[ -z "$DEVICE_SERIAL" ]]; then
  mapfile -t devices < <("$ADB_BIN" devices | awk 'NR>1 && $2=="device" {print $1}')
  if [[ "${#devices[@]}" -ne 1 ]]; then
    echo "Expected exactly one connected adb device, found ${#devices[@]}; pass DEVICE_SERIAL explicitly." >&2
    "$ADB_BIN" devices -l >&2
    exit 1
  fi
  DEVICE_SERIAL="${devices[0]}"
fi

adb_cmd() {
  if [[ -n "$DEVICE_SERIAL" ]]; then
    "$ADB_BIN" -s "$DEVICE_SERIAL" "$@"
  else
    "$ADB_BIN" "$@"
  fi
}

maestro_cmd() {
  if [[ -n "$DEVICE_SERIAL" ]]; then
    "$MAESTRO_BIN" --device "$DEVICE_SERIAL" "$@"
  else
    "$MAESTRO_BIN" "$@"
  fi
}

verify_apk_abi() {
  local device_abi
  device_abi="$(adb_cmd shell getprop ro.product.cpu.abi | tr -d '\r[:space:]')"
  if ! unzip -Z1 "$APK_PATH" | grep -qx "lib/$device_abi/libflutter.so"; then
    echo "APK $APK_PATH does not contain libflutter.so for device ABI $device_abi." >&2
    return 1
  fi
}

dismiss_anr() {
  local focus
  focus="$(adb_cmd shell dumpsys window 2>/dev/null | grep 'mCurrentFocus' || true)"
  if [[ "$focus" == *"Not Responding"* ]]; then
    echo "--- ANR detected, choosing Wait ---"
    adb_cmd shell input tap 800 1500 >/dev/null 2>&1 || true
  fi
}

disable_interfering_apps() {
  local package
  for package in \
    com.arenaton.app \
    com.arenaton.ninelives \
    com.trebuchetdynamics.melodrop; do
    adb_cmd shell pm disable-user --user 0 "$package" >/dev/null 2>&1 || true
    adb_cmd shell am force-stop "$package" >/dev/null 2>&1 || true
  done
}

install_app() {
  if [[ ! -f "$APK_PATH" ]]; then
    echo "APK not found: $APK_PATH" >&2
    return 1
  fi
  verify_apk_abi || return 1
  if adb_cmd install -r "$APK_PATH" >/dev/null 2>&1; then
    return 0
  fi

  echo "--- Existing app is incompatible with the test APK; reinstalling ---"
  adb_cmd uninstall "$APP_ID" >/dev/null 2>&1 || true
  adb_cmd install "$APK_PATH" >/dev/null
}

ensure_app_installed() {
  if ! adb_cmd shell pm path "$APP_ID" 2>/dev/null | grep -q '^package:'; then
    echo "--- App not installed; installing APK ---"
    install_app
    return
  fi

  if ! adb_cmd shell cmd package resolve-activity --brief "$ACTIVITY" \
    2>/dev/null | grep -q "$APP_ID"; then
    echo "--- App activity is not resolvable; reinstalling APK ---"
    adb_cmd uninstall "$APP_ID" >/dev/null 2>&1 || true
    install_app
  fi
}

wait_for_app_ui() {
  local elapsed=0
  local dump_path="/sdcard/maestro_boot_dump.xml"
  while ((elapsed < APP_START_TIMEOUT_SECONDS)); do
    dismiss_anr
    if adb_cmd shell dumpsys window 2>/dev/null | grep -Eq \
      "mFocusedApp=.*$APP_ID|mCurrentFocus=.*$APP_ID"; then
      echo "--- App focused after ${elapsed}s; Maestro will await its UI ---"
      return 0
    fi
    if adb_cmd shell "rm -f $dump_path; uiautomator dump $dump_path >/dev/null 2>&1" \
      >/dev/null 2>&1 &&
      adb_cmd shell cat "$dump_path" 2>/dev/null | grep -Eq \
        'Fractal Forge|Skip onboarding|Interactive fractal canvas|Exit fullscreen view|Randomize[^<]*Controls|Share & export'; then
      echo "--- App UI ready after ${elapsed}s ---"
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done

  echo "Timed out waiting ${APP_START_TIMEOUT_SECONDS}s for app UI." >&2
  return 1
}

launch_app() {
  echo "--- Ensuring app is installed ---"
  ensure_app_installed || return

  echo "--- Launching $APP_ID ---"
  adb_cmd shell am force-stop "$APP_ID" >/dev/null 2>&1 || true
  adb_cmd shell am start -n "$ACTIVITY" >/dev/null
  wait_for_app_ui
}

record_result() {
  local name="$1"
  local status="$2"
  if [[ "$status" -eq 0 ]]; then
    echo "  PASS: $name"
    RESULTS+=("PASS  $name")
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name"
    RESULTS+=("FAIL  $name")
    FAIL=$((FAIL + 1))
  fi
}

run_flow() {
  local flow="$1"
  local reuse_driver="$2"
  local name
  local status
  name="$(basename "$flow")"

  echo
  echo "=============================="
  echo "  Running: $name"
  echo "=============================="

  if ! launch_app; then
    record_result "$name" 1
    return
  fi

  if [[ "$reuse_driver" == true ]]; then
    maestro_cmd test --no-reinstall-driver "$flow" 2>&1
  else
    maestro_cmd test "$flow" 2>&1
  fi
  status=$?
  record_result "$name" "$status"
}

echo "--- Installing the requested test APK ---"
install_app || exit 1
disable_interfering_apps

run_flow .maestro/01_app_launch.yaml false
if ((FAIL > 0)); then
  echo "Maestro driver bootstrap failed; aborting dependent flows." >&2
  exit 1
fi

for flow in .maestro/0[2-5]_*.yaml; do
  run_flow "$flow" true
  disable_interfering_apps
done

echo
echo "=============================="
echo "  MAESTRO TEST SUMMARY"
echo "=============================="
printf '  %s\n' "${RESULTS[@]}"
echo
echo "  Total: $((PASS + FAIL))  Pass: $PASS  Fail: $FAIL"
echo "=============================="

((FAIL == 0))

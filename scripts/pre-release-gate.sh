#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

DEVICE="${ANDROID_DEVICE:-}"
BUILD_NAME="${RELEASE_BUILD_NAME:-}"
BUILD_NUMBER="${RELEASE_BUILD_NUMBER:-}"
SOAK_SECONDS=1800
MAX_PSS_KB="${MAX_PSS_KB:-1048576}"
MAX_PSS_GROWTH_KB="${MAX_PSS_GROWTH_KB:-393216}"
MAX_JANKY_FRAME_PERCENT="${MAX_JANKY_FRAME_PERCENT:-10}"
MIN_JANKY_FRAME_COUNT="${MIN_JANKY_FRAME_COUNT:-10}"
MAX_THERMAL_STATUS="${MAX_THERMAL_STATUS:-3}"
DRY_RUN=0
SKIP_HOST=0
PACKAGE="com.trebuchetdynamics.fractal.forge"
COMPONENT="$PACKAGE/.MainActivity"
DEVICE_ANDROID_ABI=""
DEVICE_FLUTTER_TARGET=""
LOG_DIR=""
WIFI_WAS_ENABLED=""
DATA_WAS_ENABLED=""

usage() {
  cat <<'EOF'
Usage: scripts/pre-release-gate.sh [options]

Options:
  --device ID          Flutter/ADB device ID (default: auto-discover Waydroid)
  --soak-seconds N     Monkey soak duration approximation (default: 1800)
  --build-name NAME    Version name for the production-mode APK
  --build-number N     Version code for the production-mode APK
  --log-dir DIR        Evidence output directory
  --skip-host          Skip analyzer and full host suite
  --dry-run            Print every gate without executing it
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE="$2"; shift 2 ;;
    --device=*) DEVICE="${1#*=}"; shift ;;
    --soak-seconds) SOAK_SECONDS="$2"; shift 2 ;;
    --soak-seconds=*) SOAK_SECONDS="${1#*=}"; shift ;;
    --build-name) BUILD_NAME="$2"; shift 2 ;;
    --build-name=*) BUILD_NAME="${1#*=}"; shift ;;
    --build-number) BUILD_NUMBER="$2"; shift 2 ;;
    --build-number=*) BUILD_NUMBER="${1#*=}"; shift ;;
    --log-dir) LOG_DIR="$2"; shift 2 ;;
    --log-dir=*) LOG_DIR="${1#*=}"; shift ;;
    --skip-host) SKIP_HOST=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ "$SOAK_SECONDS" =~ ^[0-9]+$ ]] || { echo "--soak-seconds must be an integer" >&2; exit 2; }
if [[ -z "$BUILD_NAME" || -z "$BUILD_NUMBER" ]]; then
  pubspec_identity="$(awk '$1 == "version:" { print $2; exit }' pubspec.yaml)"
  [[ -n "$BUILD_NAME" ]] || BUILD_NAME="${pubspec_identity%+*}"
  [[ -n "$BUILD_NUMBER" ]] || BUILD_NUMBER="${pubspec_identity##*+}"
fi
[[ -n "$BUILD_NAME" ]] || { echo "Could not resolve release build name" >&2; exit 2; }
[[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || { echo "--build-number must be an integer" >&2; exit 2; }
LOG_DIR="${LOG_DIR:-qa/pre-release-$(date -u +%Y%m%dT%H%M%SZ)}"
if [[ "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$LOG_DIR"
fi

print_command() {
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
}

run_gate() {
  local label="$1"; shift
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_command "$@"
    return 0
  fi
  printf '\n=== %s ===\n' "$label" | tee -a "$LOG_DIR/gate.log"
  "$@" 2>&1 | tee -a "$LOG_DIR/gate.log"
}

discover_device() {
  [[ -z "$DEVICE" ]] || return 0
  if [[ "$DRY_RUN" -eq 1 ]]; then
    DEVICE="auto-waydroid"
    return 0
  fi

  DEVICE="$(
    adb devices -l 2>/dev/null |
      awk '$2 == "device" && /model:WayDroid/ { print $1; exit }'
  )"
  if [[ -z "$DEVICE" ]] && command -v waydroid >/dev/null 2>&1; then
    local waydroid_ip
    waydroid_ip="$(waydroid status 2>/dev/null | awk '/^IP address:/ { print $3; exit }')"
    if [[ -n "$waydroid_ip" ]]; then
      DEVICE="${waydroid_ip}:5555"
      adb connect "$DEVICE" >/dev/null 2>&1 || true
    fi
  fi
  [[ -n "$DEVICE" ]] || {
    echo 'Could not auto-discover a live Waydroid device after the host gate; start Waydroid or pass --device.' >&2
    exit 2
  }
}

remove_instrumented_app() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_command adb -s "$DEVICE" uninstall "$PACKAGE"
    return 0
  fi
  if adb -s "$DEVICE" shell pm path "$PACKAGE" | grep -q '^package:'; then
    adb_gate "remove instrumented app" uninstall "$PACKAGE"
  fi
}

install_production_app() {
  remove_instrumented_app
  adb_gate "install production-mode device artifact" install \
    build/app/outputs/flutter-apk/app-release.apk
}

adb_gate() {
  local label="$1"; shift
  run_gate "$label" adb -s "$DEVICE" "$@"
}

collect_soak_sample() {
  local destination="$1" required_marker="$2"
  shift 2
  local output
  if ! output="$(adb -s "$DEVICE" "$@" 2>&1)"; then
    printf '%s\n' "$output" >>"$destination" || true
    return 1
  fi
  printf '%s\n' "$output" >>"$destination" || return 1
  [[ "$output" == *"$required_marker"* ]]
}

run_device_soak() {
  # Monkey can discard unsupported event categories and finish a nominal event
  # count early. Use a generous count plus a host wall-clock deadline so the
  # requested soak duration is real rather than an event-count approximation.
  local events=$((SOAK_SECONDS * 100))
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_command timeout --signal=INT --kill-after=10 "${SOAK_SECONDS}s" \
      adb -s "$DEVICE" shell monkey -p "$PACKAGE" \
      --pct-syskeys 0 --throttle 200 --ignore-crashes --ignore-timeouts "$events"
    print_command adb -s "$DEVICE" shell dumpsys meminfo "$PACKAGE"
    print_command adb -s "$DEVICE" shell dumpsys gfxinfo "$PACKAGE"
    print_command adb -s "$DEVICE" shell dumpsys battery
    print_command adb -s "$DEVICE" shell dumpsys thermalservice
    printf '+ validate bounded PSS: peak <= %s KiB, growth <= %s KiB\n' \
      "$MAX_PSS_KB" "$MAX_PSS_GROWTH_KB"
    printf '+ validate crash/ANR count: 0\n'
    printf '+ validate janky frames: <= %s%%\n' "$MAX_JANKY_FRAME_PERCENT"
    printf '+ validate thermal status: <= %s\n' "$MAX_THERMAL_STATUS"
    return 0
  fi

  printf '\n=== long-duration interaction soak ===\n' | tee -a "$LOG_DIR/gate.log"
  local soak_started_at=$SECONDS
  timeout --signal=INT --kill-after=10 "${SOAK_SECONDS}s" \
    adb -s "$DEVICE" shell monkey -p "$PACKAGE" \
    --pct-syskeys 0 --throttle 200 --ignore-crashes --ignore-timeouts "$events" \
    2>&1 | tee "$LOG_DIR/soak-monkey.log" &
  local soak_pid=$!
  local collection_failed=0
  while kill -0 "$soak_pid" 2>/dev/null; do
    date -u +%Y-%m-%dT%H:%M:%SZ >>"$LOG_DIR/soak-memory.log" ||
      collection_failed=1
    collect_soak_sample "$LOG_DIR/soak-memory.log" 'TOTAL PSS:' \
      shell dumpsys meminfo "$PACKAGE" || collection_failed=1
    collect_soak_sample "$LOG_DIR/soak-frames.log" 'Janky frames:' \
      shell dumpsys gfxinfo "$PACKAGE" framestats || collection_failed=1
    collect_soak_sample "$LOG_DIR/soak-battery.log" 'level:' \
      shell dumpsys battery || collection_failed=1
    collect_soak_sample "$LOG_DIR/soak-thermal.log" 'Thermal Status:' \
      shell dumpsys thermalservice || collection_failed=1
    sleep 60
  done
  local soak_status
  if wait "$soak_pid"; then
    soak_status=0
  else
    soak_status=$?
  fi
  local soak_elapsed=$((SECONDS - soak_started_at))
  [[ "$soak_status" -eq 124 ]] || {
    echo "Soak ended without the expected wall-clock timeout (exit ${soak_status})." >&2
    return 1
  }
  (( soak_elapsed >= SOAK_SECONDS )) || {
    echo "Soak ended after ${soak_elapsed}s; required ${SOAK_SECONDS}s." >&2
    return 1
  }
  (( collection_failed == 0 )) || {
    echo 'One or more periodic soak evidence commands failed.' >&2
    return 1
  }

  adb -s "$DEVICE" logcat -d >"$LOG_DIR/soak-logcat.log" 2>&1
  local crash_anr_count
  crash_anr_count="$(
    awk 'BEGIN { IGNORECASE = 1 }
      /FATAL EXCEPTION|ANR in |am_crash|am_anr/ { count++ }
      END { print count + 0 }' \
      "$LOG_DIR/soak-logcat.log" "$LOG_DIR/soak-monkey.log"
  )" || {
    echo "Could not inspect soak logs for crash/ANR markers." >&2
    return 1
  }
  (( crash_anr_count == 0 )) || {
    echo "Soak detected ${crash_anr_count} crash/ANR marker(s)." >&2
    return 1
  }

  local pss_output
  pss_output="$(
    awk '/TOTAL PSS:/ { value=$3; gsub(/,/, "", value); if (value ~ /^[0-9]+$/) print value }' \
      "$LOG_DIR/soak-memory.log"
  )" || {
    echo 'Could not parse soak TOTAL PSS samples.' >&2
    return 1
  }
  mapfile -t pss_samples <<< "$pss_output"
  if [[ "${#pss_samples[@]}" -lt 2 ]]; then
    echo 'Soak did not produce enough TOTAL PSS samples.' >&2
    return 1
  fi
  local first_pss="${pss_samples[0]}"
  local last_pss="${pss_samples[${#pss_samples[@]} - 1]}"
  local peak_pss=0 sample
  for sample in "${pss_samples[@]}"; do
    (( sample > peak_pss )) && peak_pss="$sample"
  done
  local growth_pss=$((last_pss - first_pss))
  printf 'Soak PSS: first=%s KiB last=%s KiB peak=%s KiB growth=%s KiB\n' \
    "$first_pss" "$last_pss" "$peak_pss" "$growth_pss" | tee -a "$LOG_DIR/gate.log"
  (( peak_pss <= MAX_PSS_KB )) || {
    echo "Peak PSS exceeded ${MAX_PSS_KB} KiB." >&2
    return 1
  }
  (( growth_pss <= MAX_PSS_GROWTH_KB )) || {
    echo "PSS growth exceeded ${MAX_PSS_GROWTH_KB} KiB." >&2
    return 1
  }

  local peak_janky_percent
  peak_janky_percent="$(awk -v min_frames="$MIN_JANKY_FRAME_COUNT" '
    /Total frames rendered:/ { frames = $4 + 0; next }
    frames >= min_frames && match($0, /Janky frames:.*\(([0-9]+([.][0-9]+)?)%\)/, value) {
      count++
      if (value[1] + 0 > peak) peak = value[1] + 0
    }
    END { if (count) print peak + 0 }
  ' "$LOG_DIR/soak-frames.log")"
  [[ -n "$peak_janky_percent" ]] || {
    echo 'Soak did not produce a janky-frame percentage sample.' >&2
    return 1
  }
  awk -v actual="$peak_janky_percent" -v limit="$MAX_JANKY_FRAME_PERCENT" \
    'BEGIN { exit !(actual <= limit) }' || {
      echo "Janky frames exceeded ${MAX_JANKY_FRAME_PERCENT}% (peak ${peak_janky_percent}%)." >&2
      return 1
    }

  local peak_thermal_status
  peak_thermal_status="$(awk '
    match($0, /[Ss]tatus:[[:space:]]*([0-9]+)/, value) {
      count++
      if (value[1] + 0 > peak) peak = value[1] + 0
    }
    END { if (count) print peak + 0 }
  ' "$LOG_DIR/soak-thermal.log")"
  [[ -n "$peak_thermal_status" ]] || {
    echo 'Soak did not produce a thermal-status sample.' >&2
    return 1
  }
  (( peak_thermal_status <= MAX_THERMAL_STATUS )) || {
    echo "Thermal status exceeded ${MAX_THERMAL_STATUS} (peak ${peak_thermal_status})." >&2
    return 1
  }
}

restore_network() {
  if [[ "$DRY_RUN" -eq 0 ]]; then
    if [[ "$WIFI_WAS_ENABLED" == "1" ]]; then
      adb -s "$DEVICE" shell svc wifi enable >/dev/null 2>&1 || true
    elif [[ "$WIFI_WAS_ENABLED" == "0" ]]; then
      adb -s "$DEVICE" shell svc wifi disable >/dev/null 2>&1 || true
    fi
    if [[ "$DATA_WAS_ENABLED" == "1" ]]; then
      adb -s "$DEVICE" shell svc data enable >/dev/null 2>&1 || true
    elif [[ "$DATA_WAS_ENABLED" == "0" ]]; then
      adb -s "$DEVICE" shell svc data disable >/dev/null 2>&1 || true
    fi
  fi
}

capture_network_state() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '+ preserve network state before offline gate\n'
    return
  fi
  WIFI_WAS_ENABLED="$(adb -s "$DEVICE" shell settings get global wifi_on | tr -d '\r')"
  DATA_WAS_ENABLED="$(adb -s "$DEVICE" shell settings get global mobile_data | tr -d '\r')"
  [[ "$WIFI_WAS_ENABLED" == "0" || "$WIFI_WAS_ENABLED" == "1" ]] ||
    WIFI_WAS_ENABLED=""
  [[ "$DATA_WAS_ENABLED" == "0" || "$DATA_WAS_ENABLED" == "1" ]] ||
    DATA_WAS_ENABLED=""
}
trap restore_network EXIT

export PATH="$HOME/flutter/bin:$PATH"

if [[ "$SKIP_HOST" -eq 0 ]]; then
  run_gate "analyzer" flutter analyze
  run_gate "full host suite" flutter test
fi

discover_device
if [[ "$DRY_RUN" -eq 0 ]]; then
  adb connect "$DEVICE" >/dev/null 2>&1 || true
  DEVICE_ANDROID_ABI="$(adb -s "$DEVICE" shell getprop ro.product.cpu.abi | tr -d '\r[:space:]')"
  case "$DEVICE_ANDROID_ABI" in
    arm64-v8a) DEVICE_FLUTTER_TARGET=android-arm64 ;;
    armeabi-v7a) DEVICE_FLUTTER_TARGET=android-arm ;;
    x86_64) DEVICE_FLUTTER_TARGET=android-x64 ;;
    *) echo "Unsupported device ABI for release gate: $DEVICE_ANDROID_ABI" >&2; exit 2 ;;
  esac
else
  DEVICE_ANDROID_ABI=x86_64
  DEVICE_FLUTTER_TARGET=android-x64
fi
adb_gate "device readiness" get-state
capture_network_state

integration_files=(
  integration_test/flows/user_flows_test.dart
  integration_test/flows/critical_journey_test.dart
  "integration_test/rendering/render_validation_test.dart"
  "integration_test/rendering/shader_family_validation_test.dart"
  "integration_test/performance/perf_smoke_test.dart"
  integration_test/accessibility/semantics_audit_test.dart
)
for test_file in "${integration_files[@]}"; do
  run_gate "device integration: $test_file" flutter test "$test_file" -d "$DEVICE"
done

# Flutter's integration-test runner uses a debug-signed instrumented package.
# Replace it with a production-mode build matching the connected device before
# exercising deep links, process death, trim-memory, and the long-running soak.
run_gate "build production-mode device artifact" \
  flutter build apk --release --target-platform "$DEVICE_FLUTTER_TARGET" \
    --android-project-arg "release-abi=$DEVICE_ANDROID_ABI" \
    --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"
install_production_app

# Exercise Android's strongest trim callback before another launch. This is not
# a substitute for the host lifecycle tests; it proves the release process can
# survive an actual platform memory-pressure signal.
SESSION_URI='https://fractal.trebuchetdynamics.com/view?type=julia'
if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '+ test deep link: %s\n' "$SESSION_URI"
fi
adb_gate "prepare durable viewer session" shell am start -W \
  -a android.intent.action.VIEW -d "$SESSION_URI" "$PACKAGE"
run_gate "wait for durable session write" sleep 3
adb_gate "critical memory pressure" shell am send-trim-memory "$PACKAGE" RUNNING_CRITICAL
adb_gate "process death" shell am force-stop "$PACKAGE"
adb_gate "process restoration launch" shell am start -W -n "$COMPONENT"
run_gate "wait for restored viewer" sleep 3
if [[ "$DRY_RUN" -eq 1 ]]; then
  print_command adb -s "$DEVICE" exec-out uiautomator dump /dev/tty
  printf '+ assert restored UI contains Julia and Controls\n'
else
  adb -s "$DEVICE" exec-out uiautomator dump /dev/tty \
    >"$LOG_DIR/process-restoration-ui.xml"
  if ! grep -q 'Julia' "$LOG_DIR/process-restoration-ui.xml" || \
     ! grep -q 'Controls' "$LOG_DIR/process-restoration-ui.xml"; then
    echo 'Process-death restoration did not return to the Julia viewer.' >&2
    exit 1
  fi
fi

if [[ -f integration_test/flows/lifecycle_restoration_test.dart || "$DRY_RUN" -eq 1 ]]; then
  run_gate "lifecycle restoration" \
    flutter test integration_test/flows/lifecycle_restoration_test.dart -d "$DEVICE"
fi

# The production manifest has no Internet permission. Explicitly disable
# device networking and rerun the reliability flow to keep that promise true.
adb_gate "offline: wifi off" shell svc wifi disable
adb_gate "offline: mobile data off" shell svc data disable
run_gate "offline critical journey" \
  flutter test integration_test/flows/critical_journey_test.dart -d "$DEVICE"
restore_network

# The lifecycle and offline integration runners remove their instrumented app.
# Reinstall the production-mode artifact so the soak measures release behavior.
install_production_app
adb_gate "launch production app for soak" shell am start -W -n "$COMPONENT"

# Constrained random interaction catches lifecycle, route, and renderer leaks.
adb_gate "clear logcat before soak" logcat -c
run_device_soak

adb_gate "memory evidence" shell dumpsys meminfo "$PACKAGE"
adb_gate "frame evidence" shell dumpsys gfxinfo "$PACKAGE"
adb_gate "battery evidence" shell dumpsys battery
adb_gate "thermal evidence" shell dumpsys thermalservice
adb_gate "crash evidence" logcat -d -b crash

if [[ "$DRY_RUN" -eq 0 ]]; then
  git diff --check | tee -a "$LOG_DIR/gate.log"
  printf 'Pre-release gate completed successfully. Evidence: %s\n' "$LOG_DIR"
else
  print_command git diff --check
fi

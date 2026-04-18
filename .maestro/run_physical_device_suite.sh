#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE_SERIAL="${DEVICE_SERIAL:-${1:-}}"
APP_ID="com.trebuchetdynamics.fractal.forge"
FLUTTER_BIN="/home/xel/flutter/bin/flutter"
MAESTRO_BIN="$HOME/.maestro/bin/maestro"
REPORT_ROOT="${REPORT_ROOT:-$ROOT_DIR/maestro_reports/physical_$(date +%Y%m%d_%H%M%S)}"
FEATURE_FLOWS=(
  ".maestro/01_app_launch.yaml"
  ".maestro/02_catalog_navigation.yaml"
  ".maestro/03_viewer_controls.yaml"
  ".maestro/04_export_flow.yaml"
  ".maestro/05_every_fractal_smoke.yaml"
)

mkdir -p "$REPORT_ROOT/flows" "$REPORT_ROOT/all_fractals"

if [[ -z "$DEVICE_SERIAL" ]]; then
  mapfile -t devices < <(adb devices | awk 'NR>1 && $2=="device" {print $1}')
  if [[ "${#devices[@]}" -ne 1 ]]; then
    echo "Expected exactly one connected adb device, found ${#devices[@]}." >&2
    adb devices -l >&2
    exit 1
  fi
  DEVICE_SERIAL="${devices[0]}"
fi

adb_cmd() {
  adb -s "$DEVICE_SERIAL" "$@"
}

maestro_cmd() {
  "$MAESTRO_BIN" --device "$DEVICE_SERIAL" "$@"
}

wake_and_unlock_device() {
  adb_cmd shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || true
  adb_cmd shell input keyevent 82 >/dev/null 2>&1 || true
}

probe_query_for_name() {
  case "$1" in
    "Dual-Quaternion Julia") printf '%s\n' "Dual" ;;
    "Mandelbox Shape Inversion") printf '%s\n' "Inversion" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

probe_regex_for_name() {
  local fractal_name="$1"
  local fractal_dimension="$2"
  case "$fractal_name" in
    "Dual-Quaternion Julia")
      printf '%s\n' ".*Dual.?Quaternion Julia fractal, $fractal_dimension.*"
      ;;
    "Lorenz Attractor")
      printf '%s\n' ".*Lorenz Attractor( \\(2D\\))? fractal, $fractal_dimension.*"
      ;;
    *)
      local escaped_name
      escaped_name="$(printf '%s' "$fractal_name" | sed -e 's/[][(){}.^$*+?|\\/]/\\\\&/g')"
      printf '%s\n' ".*$escaped_name fractal, $fractal_dimension.*"
      ;;
  esac
}

wait_for_catalog_like_ui() {
  local attempt
  for attempt in $(seq 1 120); do
    wake_and_unlock_device
    if adb_cmd shell dumpsys window | rg -q \
      "mFocusedApp=ActivityRecord.*$APP_ID/.MainActivity|mCurrentFocus=Window.*$APP_ID"; then
      return 0
    fi
    if adb_cmd shell 'rm -f /sdcard/maestro_boot_dump.xml; uiautomator dump /sdcard/maestro_boot_dump.xml >/dev/null 2>&1 || true; test -s /sdcard/maestro_boot_dump.xml'; then
      if adb_cmd shell cat /sdcard/maestro_boot_dump.xml 2>/dev/null | rg -q \
        'Fractal Forge|Skip onboarding|Back|Dismiss'; then
        return 0
      fi
    fi
    sleep 2
  done
  return 1
}

ensure_flutter_run_session() {
  local existing_pid
  existing_pid="$(pgrep -f "flutter_tools.snapshot run -d $DEVICE_SERIAL" | head -n1 || true)"
  if [[ -n "$existing_pid" ]]; then
    echo "Reusing existing flutter run session for $DEVICE_SERIAL (pid $existing_pid)."
    return 0
  fi

  echo "Starting flutter run for $DEVICE_SERIAL..."
  (
    cd "$ROOT_DIR"
    PATH="/home/xel/.local/bin:$PATH" "$FLUTTER_BIN" run -d "$DEVICE_SERIAL"
  ) >"$REPORT_ROOT/flutter_run.log" 2>&1 &
  FLUTTER_RUN_PID=$!
  export FLUTTER_RUN_PID

  if ! wait_for_catalog_like_ui; then
    echo "Timed out waiting for app UI after flutter run startup." >&2
    tail -n 120 "$REPORT_ROOT/flutter_run.log" >&2 || true
    exit 1
  fi
}

FEATURE_PASS=0
FEATURE_FAIL=0
ALL_PASS=0
ALL_FAIL=0
declare -a FAILURES=()

trap 'if [[ -n "${FLUTTER_RUN_PID:-}" ]]; then kill "$FLUTTER_RUN_PID" 2>/dev/null || true; fi' EXIT

echo "Device: $DEVICE_SERIAL"
echo "Reports: $REPORT_ROOT"

ensure_flutter_run_session

echo "Installing Maestro driver..."
if maestro_cmd test ".maestro/01_app_launch.yaml" \
  >"$REPORT_ROOT/flows/01_driver_bootstrap.log" 2>&1; then
  FEATURE_PASS=$((FEATURE_PASS + 1))
else
  FEATURE_FAIL=$((FEATURE_FAIL + 1))
  FAILURES+=("01_app_launch.yaml")
fi

for flow in "${FEATURE_FLOWS[@]:1}"; do
  flow_name="$(basename "$flow" .yaml)"
  log_path="$REPORT_ROOT/flows/${flow_name}.log"
  echo "Running feature flow: $flow"
  if maestro_cmd test --no-reinstall-driver "$flow" >"$log_path" 2>&1; then
    FEATURE_PASS=$((FEATURE_PASS + 1))
  else
    FEATURE_FAIL=$((FEATURE_FAIL + 1))
    FAILURES+=("feature:$flow")
  fi
done

echo "Running full fractal sweep..."
while IFS=$'\t' read -r fractal_name fractal_dimension; do
  [[ -n "$fractal_name" ]] || continue
  slug="$(printf '%s' "$fractal_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g; s/__\\+/_/g; s/^_//; s/_$//')"
  probe_query="$(probe_query_for_name "$fractal_name")"
  probe_regex="$(probe_regex_for_name "$fractal_name" "$fractal_dimension")"
  log_path="$REPORT_ROOT/all_fractals/${slug}.log"
  echo "  -> $fractal_name"
  if maestro_cmd test --no-reinstall-driver \
    -e FRACTAL_NAME="$fractal_name" \
    -e FRACTAL_QUERY="$probe_query" \
    -e FRACTAL_CARD_REGEX="$probe_regex" \
    ".maestro/06_single_fractal_probe.yaml" >"$log_path" 2>&1; then
    ALL_PASS=$((ALL_PASS + 1))
  else
    ALL_FAIL=$((ALL_FAIL + 1))
    FAILURES+=("fractal:$fractal_name")
  fi
done < <(
  awk '
    /^  - id:/ {
      if (name != "" && implemented == "true") print name "\t" dimension;
      name = "";
      dimension = "";
      implemented = "";
    }
    /^    name:/ {
      sub(/^    name: /, "");
      gsub(/^"/, "");
      gsub(/"$/, "");
      name = $0;
    }
    /^    dimension:/ {
      dimension = $2;
    }
    /^    implemented:/ {
      implemented = $2;
    }
    END {
      if (name != "" && implemented == "true") print name "\t" dimension;
    }
  ' "$ROOT_DIR/docs/catalog/fractal_registry.yaml"
)

summary_path="$REPORT_ROOT/summary.txt"
{
  echo "Device: $DEVICE_SERIAL"
  echo "Feature flows passed: $FEATURE_PASS"
  echo "Feature flows failed: $FEATURE_FAIL"
  echo "Fractals passed: $ALL_PASS"
  echo "Fractals failed: $ALL_FAIL"
  echo "Report root: $REPORT_ROOT"
  if [[ "${#FAILURES[@]}" -gt 0 ]]; then
    echo
    echo "Failures:"
    printf '  %s\n' "${FAILURES[@]}"
  fi
} | tee "$summary_path"

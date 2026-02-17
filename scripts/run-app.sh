#!/bin/bash
set -e

# Flutter Fractal Forge - Run App on Device or Emulator
# Usage: ./scripts/run-app.sh [options]
#
# Options:
#   --headless              Start emulator without a window (emulator fallback only)
#   --software-rendering    Pass --enable-software-rendering to flutter run
#   --mode debug|profile|release
#                           Build mode (default: debug)
#   --logcat                Stream adb logcat (Flutter + native) alongside flutter run
#   --dart-define KEY=VAL   Pass a dart-define; may be repeated
#   --device SERIAL         Force a specific device serial instead of auto-detect
#   --wifi HOST[:PORT]      Connect to device over Wi-Fi ADB (adb connect HOST:PORT)
#   --list                  List available devices and exit
#   --help                  Show this help

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Configuration ─────────────────────────────────────────────────────────────
AVD_NAME="${AVD_NAME:-fractal_test}"
EMULATOR_DEVICE_ID="${EMULATOR_DEVICE_ID:-emulator-5554}"
ANDROID_SDK="${ANDROID_SDK_ROOT:-/usr/lib/android-sdk}"
EMULATOR_BIN="${ANDROID_SDK}/emulator/emulator"

HEADLESS=false
SOFTWARE_RENDERING=false
BUILD_MODE="debug"
STREAM_LOGCAT=false
FORCE_DEVICE=""
WIFI_HOST=""
LIST_ONLY=false
DART_DEFINES=()

# ── Argument parsing ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --headless)            HEADLESS=true; shift ;;
        --software-rendering)  SOFTWARE_RENDERING=true; shift ;;
        --logcat)              STREAM_LOGCAT=true; shift ;;
        --list)                LIST_ONLY=true; shift ;;
        --help|-h)
            sed -n '/^# Options:/,/^[^#]/{ /^# /{ s/^# //; p } }' "$0"
            exit 0
            ;;
        --mode)
            BUILD_MODE="$2"; shift 2
            [[ "$BUILD_MODE" =~ ^(debug|profile|release)$ ]] || {
                echo "Unknown mode: $BUILD_MODE (use debug|profile|release)"; exit 1; }
            ;;
        --device)
            FORCE_DEVICE="$2"; shift 2 ;;
        --wifi)
            WIFI_HOST="$2"; shift 2 ;;
        --dart-define)
            DART_DEFINES+=("--dart-define=$2"); shift 2 ;;
        --dart-define=*)
            DART_DEFINES+=("$1"); shift ;;
        *) shift ;;
    esac
done

# ── Colors ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ────────────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}  $*${NC}"; }
ok()      { echo -e "${GREEN}✓ $*${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $*${NC}"; }
fail()    { echo -e "${RED}✗ $*${NC}"; exit 1; }

device_model() {
    local serial="$1"
    local model brand
    model=$(adb -s "$serial" shell getprop ro.product.model 2>/dev/null | tr -d '\r\n')
    brand=$(adb -s "$serial" shell getprop ro.product.brand 2>/dev/null | tr -d '\r\n')
    echo "${brand} ${model}"
}

device_android_version() {
    local serial="$1"
    adb -s "$serial" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r\n'
}

print_device_table() {
    echo ""
    echo -e "${BOLD}Connected devices:${NC}"
    printf "  %-24s %-12s %-30s %s\n" "SERIAL" "STATE" "MODEL" "ANDROID"
    printf "  %-24s %-12s %-30s %s\n" "------" "-----" "-----" "-------"
    while IFS= read -r line; do
        [[ "$line" =~ ^List ]] && continue
        [[ -z "$line" ]] && continue
        serial=$(echo "$line" | awk '{print $1}')
        state=$(echo "$line"  | awk '{print $2}')
        if [[ "$state" == "device" ]]; then
            model=$(device_model "$serial")
            android=$(device_android_version "$serial")
        else
            model="-"
            android="-"
        fi
        printf "  %-24s %-12s %-30s %s\n" "$serial" "$state" "$model" "$android"
    done < <(adb devices | tail -n +2)
    echo ""
}

# ── Prerequisite checks ────────────────────────────────────────────────────────
command -v adb    &>/dev/null || fail "adb not found in PATH (install Android platform-tools)"
command -v flutter &>/dev/null || fail "flutter not found in PATH"

echo -e "${GREEN}${BOLD}=== Flutter Fractal Forge – Run App ===${NC}"
info "mode=${BUILD_MODE}  logcat=${STREAM_LOGCAT}  defines=${DART_DEFINES[*]:-none}"
echo ""

# ── --list ─────────────────────────────────────────────────────────────────────
if [[ "$LIST_ONLY" == true ]]; then
    print_device_table
    exit 0
fi

# ── Wi-Fi ADB connect ──────────────────────────────────────────────────────────
if [[ -n "$WIFI_HOST" ]]; then
    # Default port 5555 when none given
    WIFI_ADDR="${WIFI_HOST}"
    [[ "$WIFI_HOST" != *:* ]] && WIFI_ADDR="${WIFI_HOST}:5555"
    echo -e "${YELLOW}Connecting to ${WIFI_ADDR} over Wi-Fi ADB...${NC}"
    if adb connect "$WIFI_ADDR" 2>&1 | grep -q "connected"; then
        ok "Connected to $WIFI_ADDR"
        FORCE_DEVICE="$WIFI_ADDR"
    else
        fail "Could not connect to $WIFI_ADDR – check IP, port 5555 open, and 'adb tcpip 5555' ran first"
    fi
fi

# ── Device selection ───────────────────────────────────────────────────────────
DEVICE_ID=""

if [[ -n "$FORCE_DEVICE" ]]; then
    echo -e "${YELLOW}Using forced device: $FORCE_DEVICE${NC}"
    DEVICE_ID="$FORCE_DEVICE"
else
    echo -e "${YELLOW}Scanning for physical device...${NC}"

    # Parse adb devices output; skip offline/unauthorized for now
    while IFS= read -r line; do
        [[ "$line" =~ ^List ]] && continue
        [[ -z "$line" ]] && continue
        serial=$(echo "$line" | awk '{print $1}')
        state=$(echo "$line"  | awk '{print $2}')

        # Skip emulators
        [[ "$serial" =~ ^emulator ]] && continue

        if [[ "$state" == "unauthorized" ]]; then
            warn "Physical device ${serial} is UNAUTHORIZED"
            info  "→ On your phone, open the USB debugging prompt and tap 'Allow'"
            info  "→ Then re-run this script"
            # Keep scanning; there may be another device
            continue
        fi

        if [[ "$state" == "offline" ]]; then
            warn "Physical device ${serial} is OFFLINE – try unplugging and re-plugging"
            continue
        fi

        if [[ "$state" == "device" ]]; then
            DEVICE_ID="$serial"
            break
        fi
    done < <(adb devices | tail -n +2)

    if [[ -n "$DEVICE_ID" ]]; then
        MODEL=$(device_model "$DEVICE_ID")
        ANDROID_VER=$(device_android_version "$DEVICE_ID")
        ok "Physical device: ${BOLD}${MODEL}${NC}${GREEN} (${DEVICE_ID}, Android ${ANDROID_VER})"
    else
        warn "No ready physical device found – falling back to emulator"

        # ── Emulator fallback ──────────────────────────────────────────────────
        if [[ ! -f "$EMULATOR_BIN" ]]; then
            fail "Emulator not found at: $EMULATOR_BIN\nInstall Android SDK emulator or connect a physical device."
        fi

        RUNNING_EMU=$(adb devices | awk '/^emulator/ && $2=="device" {print $1; exit}')

        if [[ -n "$RUNNING_EMU" ]]; then
            DEVICE_ID="$RUNNING_EMU"
            ok "Reusing running emulator: $DEVICE_ID"
        else
            echo -e "${YELLOW}Starting emulator ${AVD_NAME}...${NC}"
            EMU_FLAGS="-avd $AVD_NAME -no-audio"
            [[ "$HEADLESS" == true ]] && EMU_FLAGS="$EMU_FLAGS -no-window -no-boot-anim"
            nohup "$EMULATOR_BIN" $EMU_FLAGS >/tmp/emulator.log 2>&1 &
            ok "Emulator launched (PID: $!)"

            echo -e "${YELLOW}Waiting for device to appear...${NC}"
            adb wait-for-device

            DEVICE_ID="$EMULATOR_DEVICE_ID"
            echo -e "${YELLOW}Waiting for boot...${NC}"
            BOOT_TIMEOUT=120
            ELAPSED=0
            while [[ "$(adb -s "$DEVICE_ID" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
                [[ $ELAPSED -ge $BOOT_TIMEOUT ]] && fail "Boot timeout after ${BOOT_TIMEOUT}s"
                printf "."
                sleep 3; ELAPSED=$((ELAPSED + 3))
            done
            echo ""
            ok "Emulator booted"
        fi
    fi
fi

# ── Final device sanity check ──────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}Verifying device ${DEVICE_ID}...${NC}"

DEVICE_STATE=$(adb devices | awk -v id="$DEVICE_ID" '$1==id {print $2}')

case "$DEVICE_STATE" in
    device)
        ok "Device is online" ;;
    unauthorized)
        fail "Device ${DEVICE_ID} is UNAUTHORIZED\n  → Accept the RSA fingerprint prompt on your phone" ;;
    offline)
        fail "Device ${DEVICE_ID} is OFFLINE\n  → Try: adb kill-server && adb start-server" ;;
    "")
        fail "Device ${DEVICE_ID} not found in 'adb devices'" ;;
    *)
        fail "Device ${DEVICE_ID} has unexpected state: ${DEVICE_STATE}" ;;
esac

# ── Build flutter run command ──────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}=== Launching app ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# lld workaround (Linux desktop)
if [[ -f "$HOME/.local/bin/clang++" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    info "Using custom clang++ wrapper from ~/.local/bin"
fi

FLUTTER_ARGS=("-d" "$DEVICE_ID" "--$BUILD_MODE")
[[ "$SOFTWARE_RENDERING" == true ]] && FLUTTER_ARGS+=("--enable-software-rendering")
FLUTTER_ARGS+=("${DART_DEFINES[@]}")

info "flutter run ${FLUTTER_ARGS[*]}"
echo ""

# ── Optional logcat streaming ──────────────────────────────────────────────────
LOGCAT_PID=""
if [[ "$STREAM_LOGCAT" == true ]]; then
    LOG_FILE="/tmp/fractal-logcat-${DEVICE_ID//[^a-zA-Z0-9]/_}.log"
    adb -s "$DEVICE_ID" logcat -c 2>/dev/null || true   # clear buffer
    adb -s "$DEVICE_ID" logcat \
        -v time \
        -s flutter:V AndroidRuntime:E System.err:W \
        > "$LOG_FILE" 2>/dev/null &
    LOGCAT_PID=$!
    ok "Logcat streaming to: ${LOG_FILE}  (PID: ${LOGCAT_PID})"
    info "  Tail live: tail -f ${LOG_FILE}"
    echo ""
fi

# ── Cleanup trap ───────────────────────────────────────────────────────────────
cleanup() {
    if [[ -n "$LOGCAT_PID" ]]; then
        kill "$LOGCAT_PID" 2>/dev/null || true
        info "Logcat stream stopped"
    fi
}
trap cleanup EXIT INT TERM

# ── Run ────────────────────────────────────────────────────────────────────────
flutter run "${FLUTTER_ARGS[@]}"

echo ""
ok "App session ended"

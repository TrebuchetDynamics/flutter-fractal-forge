#!/bin/bash
set -e

# Flutter Fractal Forge - Run App on Emulator
# Usage: ./scripts/run-emulator-app.sh [--headless]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
AVD_NAME="${AVD_NAME:-fractal_test}"
DEVICE_ID="${DEVICE_ID:-emulator-5554}"
ANDROID_SDK="${ANDROID_SDK_ROOT:-/usr/lib/android-sdk}"
EMULATOR_BIN="${ANDROID_SDK}/emulator/emulator"
HEADLESS=false

# Parse arguments
if [[ "$1" == "--headless" ]]; then
    HEADLESS=true
fi

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Flutter Fractal Forge - Emulator Runner ===${NC}"
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found in PATH${NC}"
    echo "Please install Flutter or add it to your PATH"
    exit 1
fi

# Check if emulator binary exists
if [[ ! -f "$EMULATOR_BIN" ]]; then
    echo -e "${RED}✗ Emulator not found at: $EMULATOR_BIN${NC}"
    echo "Please install Android SDK emulator"
    exit 1
fi

# Check if emulator is already running
echo -e "${YELLOW}Checking emulator status...${NC}"
RUNNING_EMULATORS=$(adb devices | grep emulator | grep -v offline | wc -l)

if [[ "$RUNNING_EMULATORS" -eq 0 ]]; then
    echo -e "${YELLOW}✓ No emulator running, starting $AVD_NAME...${NC}"

    # Start emulator in background
    if [[ "$HEADLESS" == true ]]; then
        echo "  Starting in headless mode (no window)..."
        nohup "$EMULATOR_BIN" -avd "$AVD_NAME" \
            -no-window -no-audio -no-boot-anim \
            -gpu swiftshader_indirect \
            > /tmp/emulator.log 2>&1 &
    else
        echo "  Starting with GUI window..."
        nohup "$EMULATOR_BIN" -avd "$AVD_NAME" \
            -no-audio \
            -gpu swiftshader_indirect \
            > /tmp/emulator.log 2>&1 &
    fi

    EMULATOR_PID=$!
    echo -e "${GREEN}✓ Emulator started (PID: $EMULATOR_PID)${NC}"

    # Wait for device to appear
    echo -e "${YELLOW}Waiting for emulator device...${NC}"
    adb wait-for-device

    # Wait for boot to complete
    echo -e "${YELLOW}Waiting for boot to complete...${NC}"
    BOOT_TIMEOUT=120
    ELAPSED=0
    while [[ "$(adb -s "$DEVICE_ID" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
        if [[ $ELAPSED -ge $BOOT_TIMEOUT ]]; then
            echo -e "${RED}✗ Boot timeout after ${BOOT_TIMEOUT}s${NC}"
            exit 1
        fi
        echo -n "."
        sleep 3
        ELAPSED=$((ELAPSED + 3))
    done
    echo ""
    echo -e "${GREEN}✓ Emulator booted successfully!${NC}"
else
    echo -e "${GREEN}✓ Emulator already running${NC}"
fi

# Verify device is online
echo ""
echo -e "${YELLOW}Verifying device status...${NC}"
DEVICE_STATUS=$(adb devices | grep "$DEVICE_ID" | awk '{print $2}')

if [[ "$DEVICE_STATUS" != "device" ]]; then
    echo -e "${RED}✗ Device $DEVICE_ID is not ready (status: $DEVICE_STATUS)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Device $DEVICE_ID is online${NC}"

# Check if Flutter can see the device
echo ""
echo -e "${YELLOW}Checking Flutter device list...${NC}"
if ! flutter devices | grep -q "$DEVICE_ID"; then
    echo -e "${RED}✗ Flutter cannot see device $DEVICE_ID${NC}"
    echo "Running 'flutter devices' to debug:"
    flutter devices
    exit 1
fi

echo -e "${GREEN}✓ Flutter can see device $DEVICE_ID${NC}"

# Run the app
echo ""
echo -e "${GREEN}=== Running Flutter app ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Use environment PATH override if needed (for lld workaround)
if [[ -f "$HOME/.local/bin/clang++" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "${YELLOW}Note: Using custom clang++ wrapper from ~/.local/bin${NC}"
fi

# Run Flutter app
flutter run -d "$DEVICE_ID"

echo ""
echo -e "${GREEN}✓ App session ended${NC}"

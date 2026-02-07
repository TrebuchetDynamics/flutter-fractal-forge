#!/bin/bash

# emu-tap.sh
# Taps a coordinate on the Android emulator screen and captures a screenshot
# Usage: ./scripts/emu-tap.sh <x> <y>
# Example: ./scripts/emu-tap.sh 540 400
# Output: Prints confirmation to stdout, saves screenshot to /tmp/emu-screenshot.png

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# VALIDATE ARGUMENTS
# ============================================================================

if [ $# -ne 2 ]; then
    echo -e "${RED}[ERROR] Invalid arguments${NC}"
    echo "Usage: $0 <x> <y>"
    echo "Example: $0 540 400"
    echo ""
    echo "Common emulator dimensions:"
    echo "  Nexus 5X:     1080x1920"
    echo "  Pixel 3:      1080x2160"
    echo "  Pixel 4:      1080x2280"
    exit 1
fi

X=$1
Y=$2

# Validate that X and Y are numbers
if ! [[ "$X" =~ ^[0-9]+$ ]] || ! [[ "$Y" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}[ERROR] X and Y must be positive integers${NC}"
    exit 1
fi

echo -e "${BLUE}[TAP] Coordinates: x=$X y=$Y${NC}"

# ============================================================================
# CHECK EMULATOR IS RUNNING
# ============================================================================

DEVICES=$(adb devices 2>/dev/null | grep -v "List of attached devices" | grep -v "^$" | awk '{print $1}')

if [ -z "$DEVICES" ]; then
    echo -e "${RED}[ERROR] No Android devices found. Is the emulator running?${NC}"
    exit 1
fi

# Use first device if multiple
DEVICE=$(echo "$DEVICES" | head -1)
echo -e "${GREEN}[OK] Device found: $DEVICE${NC}"

# ============================================================================
# PERFORM TAP
# ============================================================================

echo -e "${BLUE}[TAP] Tapping at ($X, $Y)...${NC}"

if ! adb -s "$DEVICE" shell input tap "$X" "$Y" 2>/dev/null; then
    echo -e "${RED}[ERROR] Failed to send tap command${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Tap sent${NC}"

# ============================================================================
# WAIT AND CAPTURE SCREENSHOT
# ============================================================================

echo -e "${BLUE}[WAIT] Waiting 2 seconds for UI to respond...${NC}"
sleep 2

echo -e "${BLUE}[SCREENSHOT] Capturing screenshot...${NC}"

if adb -s "$DEVICE" shell screencap -p /sdcard/screenshot.png 2>/dev/null && \
   adb -s "$DEVICE" pull /sdcard/screenshot.png /tmp/emu-screenshot.png 2>/dev/null && \
   adb -s "$DEVICE" shell rm /sdcard/screenshot.png 2>/dev/null; then
    echo -e "${GREEN}[SUCCESS] Screenshot saved to /tmp/emu-screenshot.png${NC}"
else
    echo -e "${RED}[ERROR] Failed to capture screenshot${NC}"
    exit 1
fi

# ============================================================================
# PRINT SUMMARY
# ============================================================================

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}[COMPLETE] Tap and screenshot finished${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo "Tap location:  ($X, $Y)"
echo "Screenshot:    /tmp/emu-screenshot.png"

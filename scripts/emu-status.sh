#!/bin/bash

# emu-status.sh
# Provides comprehensive status of Android emulator running Flutter Fractal Forge app
# Usage: ./scripts/emu-status.sh
# Output: Prints summary to stdout and saves detailed logs to /tmp/emu-*.* files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[EMU-STATUS] Starting emulator diagnostics...${NC}"

# ============================================================================
# 1. CHECK IF EMULATOR IS RUNNING
# ============================================================================

DEVICES=$(adb devices 2>/dev/null | grep -v "List of attached devices" | grep -v "^$" | awk '{print $1}')

if [ -z "$DEVICES" ]; then
    echo -e "${RED}[ERROR] No Android devices found. Is the emulator running?${NC}"
    exit 1
fi

DEVICE_COUNT=$(echo "$DEVICES" | wc -l)
echo -e "${GREEN}[OK] Found $DEVICE_COUNT device(s)${NC}"
echo "Devices: $DEVICES"

# Use first device if multiple
DEVICE=$(echo "$DEVICES" | head -1)
echo "Using device: $DEVICE"

# ============================================================================
# 2. TAKE SCREENSHOT
# ============================================================================

echo -e "\n${BLUE}[SCREENSHOT] Capturing screenshot...${NC}"
if adb -s "$DEVICE" shell screencap -p /sdcard/screenshot.png 2>/dev/null && \
   adb -s "$DEVICE" pull /sdcard/screenshot.png /tmp/emu-screenshot.png 2>/dev/null && \
   adb -s "$DEVICE" shell rm /sdcard/screenshot.png 2>/dev/null; then
    echo -e "${GREEN}[OK] Screenshot saved to /tmp/emu-screenshot.png${NC}"
    SCREENSHOT_PATH="/tmp/emu-screenshot.png"
else
    echo -e "${YELLOW}[WARN] Failed to capture screenshot${NC}"
    SCREENSHOT_PATH="(failed)"
fi

# ============================================================================
# 3. CAPTURE FLUTTER LOGS
# ============================================================================

echo -e "\n${BLUE}[LOGS] Capturing Flutter logs...${NC}"
if adb -s "$DEVICE" logcat -d -s flutter > /tmp/emu-all-flutter.log 2>/dev/null; then
    tail -50 /tmp/emu-all-flutter.log > /tmp/emu-flutter.log
    FLUTTER_LOG_LINES=$(wc -l < /tmp/emu-flutter.log)
    echo -e "${GREEN}[OK] Captured $FLUTTER_LOG_LINES lines of Flutter logs${NC}"
else
    echo -e "${YELLOW}[WARN] Failed to capture Flutter logs${NC}"
fi

# Check for errors in Flutter logs
FLUTTER_ERRORS=$(grep -i "error\|exception\|fatal" /tmp/emu-flutter.log 2>/dev/null | wc -l)
if [ "$FLUTTER_ERRORS" -gt 0 ]; then
    echo -e "${YELLOW}[WARN] Found $FLUTTER_ERRORS error(s) in Flutter logs${NC}"
fi

# ============================================================================
# 4. DUMP UI HIERARCHY
# ============================================================================

echo -e "\n${BLUE}[UI-HIERARCHY] Dumping UI hierarchy...${NC}"
if adb -s "$DEVICE" shell uiautomator dump /sdcard/ui.xml 2>/dev/null && \
   adb -s "$DEVICE" pull /sdcard/ui.xml /tmp/emu-ui.xml 2>/dev/null && \
   adb -s "$DEVICE" shell rm /sdcard/ui.xml 2>/dev/null; then
    echo -e "${GREEN}[OK] UI hierarchy saved to /tmp/emu-ui.xml${NC}"
else
    echo -e "${YELLOW}[WARN] Failed to dump UI hierarchy${NC}"
fi

# ============================================================================
# 5. GET CURRENT ACTIVITY
# ============================================================================

echo -e "\n${BLUE}[ACTIVITY] Getting current activity...${NC}"
CURRENT_ACTIVITY=$(adb -s "$DEVICE" shell dumpsys activity activities 2>/dev/null | grep mResumedActivity | head -1 | sed 's/.*mResumedActivity=//' | tr -d ' ')

if [ -z "$CURRENT_ACTIVITY" ]; then
    echo -e "${YELLOW}[WARN] Could not determine current activity${NC}"
    CURRENT_ACTIVITY="(unknown)"
else
    echo -e "${GREEN}[OK] Current activity: ${NC}$CURRENT_ACTIVITY"
fi

# ============================================================================
# 6. PRINT SUMMARY
# ============================================================================

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}EMULATOR STATUS SUMMARY${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

echo -e "Device:            ${GREEN}$DEVICE${NC}"
echo -e "Status:            ${GREEN}ONLINE${NC}"
echo -e "Current Activity:  ${GREEN}$CURRENT_ACTIVITY${NC}"
echo -e "Screenshot:        ${GREEN}$SCREENSHOT_PATH${NC}"
echo -e "Flutter Logs:      ${GREEN}/tmp/emu-flutter.log${NC}"
echo -e "UI Hierarchy:      ${GREEN}/tmp/emu-ui.xml${NC}"

if [ "$FLUTTER_ERRORS" -gt 0 ]; then
    echo -e "Flutter Errors:    ${YELLOW}$FLUTTER_ERRORS found${NC}"
else
    echo -e "Flutter Errors:    ${GREEN}None${NC}"
fi

echo -e "\n${BLUE}Files available for analysis:${NC}"
echo "  - /tmp/emu-screenshot.png     (PNG image for visual inspection)"
echo "  - /tmp/emu-flutter.log         (Last 50 lines of Flutter logs)"
echo "  - /tmp/emu-ui.xml              (UI hierarchy dump)"
echo "  - /tmp/emu-all-flutter.log     (Full Flutter logs)"

echo -e "\n${GREEN}[SUCCESS] Emulator diagnostics complete${NC}"

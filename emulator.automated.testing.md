# Automated Emulator Testing with LLM Agents

Run a Flutter app in an Android emulator and let an LLM agent continuously test, find issues, fix them, and improve the app in an endless loop.

## Prerequisites

- Flutter SDK on PATH
- Android SDK with cmdline-tools at `/usr/lib/android-sdk`
- KVM support for emulator acceleration: `sudo apt install qemu-kvm`
- An LLM agent with shell access (Claude Code, Codex CLI, Aider, etc.)

## 1. Emulator Setup

### Install system image and create AVD

```bash
sdkmanager --sdk_root=/usr/lib/android-sdk "system-images;android-34;google_apis;x86_64"
avdmanager create avd -n fractal_test -k "system-images;android-34;google_apis;x86_64" --device "pixel_6"
```

### Launch emulator headless (for CI/agent use)

```bash
/usr/lib/android-sdk/emulator/emulator -avd fractal_test -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect &
```

### Wait for emulator to boot

```bash
adb wait-for-device
adb shell getprop sys.boot_completed | grep -q 1
```

### Full boot-wait script

```bash
#!/bin/bash
# wait-for-emulator.sh
echo "Waiting for emulator to boot..."
adb wait-for-device
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
  sleep 2
done
echo "Emulator ready."
```

## 2. Running the App on Emulator

```bash
# Install and run debug build
flutter run -d emulator-5554

# Or build + install separately
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.fractals.flutter_fractals/.MainActivity
```

## 3. Integration Tests on Emulator

```bash
# Run all integration tests on the connected emulator
flutter test integration_test/app_test.dart -d emulator-5554

# Run with verbose output for agent consumption
flutter test integration_test/app_test.dart -d emulator-5554 --reporter expanded
```

## 4. Capturing Screenshots and Logs

### Device screenshots

```bash
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./screenshots/
```

### Device logs (logcat)

```bash
# Flutter app logs only
adb logcat -s flutter 2>&1 | tee device.log

# All logs with timestamp
adb logcat -v time 2>&1 | tee full_device.log
```

### In-app debug runner logs

The app writes structured logs to the device at:
```
/data/data/com.fractals.flutter_fractals/app_flutter/debug_logs/
```

Pull them:

```bash
adb shell run-as com.fractals.flutter_fractals cat app_flutter/debug_logs/session_*.log
```

## 5. The Endless Improvement Loop

### Concept

An LLM agent runs a continuous cycle:

```
TEST -> ANALYZE -> FIX -> BUILD -> TEST -> ANALYZE -> FIX -> ...
```

Each cycle:
1. Runs integration tests and collects results
2. Captures screenshots at key states
3. Reads logs for errors and warnings
4. Analyzes failures and identifies root causes
5. Fixes issues in the codebase
6. Rebuilds and hot-restarts
7. Verifies fixes pass
8. Looks for new improvements to make
9. Repeats

### Agent Loop Script

```bash
#!/bin/bash
# agent-test-loop.sh
# Run this, then point your LLM agent at the output

ITERATION=0
LOG_DIR="./agent_test_logs"
mkdir -p "$LOG_DIR"

while true; do
  ITERATION=$((ITERATION + 1))
  echo "========================================="
  echo "ITERATION $ITERATION - $(date)"
  echo "========================================="

  # Step 1: Build
  echo "[BUILD] Building debug APK..."
  flutter build apk --debug 2>&1 | tee "$LOG_DIR/build_$ITERATION.log"
  BUILD_EXIT=$?

  if [ $BUILD_EXIT -ne 0 ]; then
    echo "[BUILD FAILED] See $LOG_DIR/build_$ITERATION.log"
    echo "AGENT_ACTION_REQUIRED: Fix build errors"
    # Agent reads this file, fixes errors, continues
    sleep 5
    continue
  fi

  # Step 2: Install on emulator
  adb install -r build/app/outputs/flutter-apk/app-debug.apk

  # Step 3: Run integration tests
  echo "[TEST] Running integration tests..."
  flutter test integration_test/app_test.dart -d emulator-5554 \
    --reporter expanded 2>&1 | tee "$LOG_DIR/test_$ITERATION.log"
  TEST_EXIT=$?

  # Step 4: Capture screenshots
  echo "[SCREENSHOT] Capturing current state..."
  adb shell screencap -p /sdcard/screen_$ITERATION.png
  adb pull /sdcard/screen_$ITERATION.png "$LOG_DIR/"

  # Step 5: Collect device logs
  echo "[LOGS] Pulling device logs..."
  adb logcat -d -s flutter > "$LOG_DIR/logcat_$ITERATION.log" 2>&1
  adb logcat -c  # Clear for next iteration

  # Step 6: Collect in-app debug logs
  adb shell run-as com.fractals.flutter_fractals \
    cat app_flutter/debug_logs/session_*.log \
    > "$LOG_DIR/app_debug_$ITERATION.log" 2>/dev/null

  # Step 7: Generate summary for agent
  echo "[SUMMARY] Iteration $ITERATION" > "$LOG_DIR/summary_$ITERATION.txt"
  echo "Build: $([ $BUILD_EXIT -eq 0 ] && echo PASS || echo FAIL)" >> "$LOG_DIR/summary_$ITERATION.txt"
  echo "Tests: $([ $TEST_EXIT -eq 0 ] && echo PASS || echo FAIL)" >> "$LOG_DIR/summary_$ITERATION.txt"
  echo "Timestamp: $(date -Iseconds)" >> "$LOG_DIR/summary_$ITERATION.txt"

  if [ $TEST_EXIT -eq 0 ]; then
    echo "[ALL PASS] Looking for improvements..."
    echo "AGENT_ACTION: All tests pass. Analyze for improvements."
  else
    echo "[TEST FAILED] Analyzing failures..."
    echo "AGENT_ACTION_REQUIRED: Fix test failures"
  fi

  # Pause between iterations
  sleep 10
done
```

### LLM Agent Prompt Template

Give this prompt to your LLM agent (Claude Code, etc.):

```
You are an autonomous QA and improvement agent for the Flutter Fractal Forge app.

Your job is to run an endless loop:
1. Read the latest test results from ./agent_test_logs/
2. If tests FAIL: analyze the failure, read relevant source files, fix the bug
3. If tests PASS: look for improvements:
   - Performance optimizations
   - Better error handling
   - UI/UX improvements
   - Missing test coverage
   - Code quality issues
4. After making changes, rebuild and re-test
5. Never stop. Always find the next thing to improve.

Commands available:
- flutter build apk --debug
- flutter test integration_test/app_test.dart -d emulator-5554
- adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png
- adb logcat -s flutter

Project structure:
- lib/core/services/ - Business logic and services
- lib/features/ - UI screens and widgets
- lib/l10n/ - Localization
- integration_test/ - Integration tests
- test/ - Unit tests

Rules:
- Always run tests after changes to verify fixes
- Never break existing passing tests
- Commit working improvements with descriptive messages
- Log what you found, what you changed, and why
- If stuck on an issue for 3 attempts, document it and move on
```

### Claude Code Specific

With Claude Code, use the autopilot or ralph mode:

```bash
# Start Claude Code with the endless improvement task
claude "ralph: Continuously test the Flutter Fractal Forge app on the emulator,
fix any issues found, and keep improving. Run integration tests, read logs,
capture screenshots, analyze results, and fix/improve the codebase.
Never stop until I say so."
```

Or use the ultraqa skill for test-fix cycling:

```bash
claude "/oh-my-claudecode:ultraqa Run integration tests on emulator-5554,
fix failures, then look for improvements. Cycle until all tests pass
and code quality is excellent."
```

## 6. Monitoring the Agent

### Watch test results in real-time

```bash
tail -f agent_test_logs/test_*.log
```

### Check iteration summaries

```bash
cat agent_test_logs/summary_*.txt
```

### View screenshots

```bash
# Open latest screenshot
xdg-open agent_test_logs/screen_*.png
```

### Stop the loop

```bash
# Kill the loop script
kill %1

# Or in Claude Code
cancelomc
```

## 7. CI/CD Integration

### GitHub Actions example

```yaml
name: Emulator Test Loop
on: workflow_dispatch

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.7'
      - name: Enable KVM
        run: |
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666"' | sudo tee /etc/udev/rules.d/99-kvm.rules
          sudo udevadm control --reload-rules
          sudo udevadm trigger
      - name: Start emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          target: google_apis
          arch: x86_64
          script: flutter test integration_test/app_test.dart -d emulator-5554
```

## 8. Tips

- **Headless emulator** (`-no-window`) uses less resources and is ideal for agent use
- **swiftshader_indirect** GPU mode works without a physical GPU
- **Hot restart** (`r` in flutter run) is faster than full rebuild for small changes
- **ADB reverse** (`adb reverse tcp:8080 tcp:8080`) forwards ports from device to host
- Keep test iterations under 5 minutes to maintain fast feedback loops
- Use `flutter test --coverage` periodically to track test coverage trends
- Screenshots are useful for visual regression testing between iterations

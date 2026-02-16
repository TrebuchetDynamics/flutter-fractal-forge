# Automated Emulator Testing for Flutter Fractal Forge

This document defines a practical workflow for running Android emulator tests with an LLM agent, collecting reliable artifacts, and triaging shader failures quickly.

## Scope and Expectations

- Emulator is the primary environment for automated functional testing.
- Emulator is not the source of truth for final GPU shader correctness or performance.
- Any shader/performance issue found on emulator should be verified on at least one physical Android device before final sign-off.

## Quick Start (Recommended)

Use the repo's one-shot headless runner:

```bash
scripts/headless-emulator-test.sh
```

For flaky/offline emulator sessions, prefer a cold boot (no quickboot snapshot):

```bash
REUSE_EXISTING=0 KEEP_EMULATOR=1 WIPE_DATA=1 scripts/headless-emulator-test.sh
```

Common variations:

```bash
# Keep emulator alive after test run
KEEP_EMULATOR=1 scripts/headless-emulator-test.sh

# Override test command
scripts/headless-emulator-test.sh flutter test integration_test/ -d "$DEVICE" --reporter expanded
```

Artifacts are written under `agent_test_logs/headless/` by default.

## Prerequisites

- Linux host with KVM acceleration (`qemu-kvm` installed).
- Flutter SDK available (`$HOME/flutter/bin` or `/home/xel/flutter/bin`).
- Android SDK at `/usr/lib/android-sdk`.
- `ANDROID_SDK_ROOT=/usr/lib/android-sdk`.
- `adb`, `flutter`, emulator binary, and `sdkmanager` available.

Recommended shell setup:

```bash
export PATH="$HOME/.local/bin:$HOME/flutter/bin:$PATH"
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
```

## 1. Emulator Setup (One-Time)

Install image and create AVD:

```bash
/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager \
  --sdk_root=/usr/lib/android-sdk \
  "platform-tools" \
  "emulator" \
  "system-images;android-34;google_apis;x86_64"

/usr/lib/android-sdk/cmdline-tools/latest/bin/avdmanager create avd \
  -n fractal_test \
  -k "system-images;android-34;google_apis;x86_64" \
  --device "pixel_6"
```

Launch emulator:

```bash
# Interactive
/usr/lib/android-sdk/emulator/emulator -avd fractal_test -no-audio -gpu swiftshader_indirect

# Headless
/usr/lib/android-sdk/emulator/emulator -avd fractal_test -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect
```

Wait for full boot:

```bash
adb wait-for-device
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
  sleep 3
done
```

## 2. Run Modes for Testing

Debug smoke run:

```bash
flutter run -d emulator-5554
```

Shader-focused run (profile + Impeller):

```bash
flutter run --profile --enable-impeller -d emulator-5554
```

Attach for live diagnostics:

```bash
flutter attach -d emulator-5554
```

Note: this repo currently sets `io.flutter.embedding.android.EnableImpeller=false` in `android/app/src/main/AndroidManifest.xml`; use runtime flags for targeted Impeller passes.

## 3. Integration Test Commands

Single target:

```bash
flutter test integration_test/app_test.dart -d emulator-5554 --reporter expanded
```

Whole integration suite:

```bash
flutter test integration_test/ -d emulator-5554 --reporter expanded
```

Useful GPU-focused targets in this repo:

- `integration_test/render_validation_test.dart`
- `integration_test/perf_smoke_test.dart`
- `integration_test/shader_benchmark_test.dart`

AR permission path checks:

```bash
adb shell pm revoke com.fractals.flutter_fractals android.permission.CAMERA
adb shell pm grant com.fractals.flutter_fractals android.permission.CAMERA
```

## 4. Deterministic Artifact Capture

Inside `integration_test`, settle frames before screenshot:

```dart
final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    as IntegrationTestWidgetsFlutterBinding;

await tester.pumpAndSettle();
await binding.takeScreenshot('viewer_loaded');
```

ADB screenshot:

```bash
adb -s emulator-5554 shell screencap -p /sdcard/screen.png
adb -s emulator-5554 pull /sdcard/screen.png ./screenshots/
```

Log capture:

```bash
# Flutter logs
adb -s emulator-5554 logcat -d -s flutter > flutter.log

# Full timestamped logs
adb -s emulator-5554 logcat -d -v time > full.log
```

In-app debug logs:

```bash
adb shell run-as com.fractals.flutter_fractals \
  cat app_flutter/debug_logs/session_*.log
```

Helper scripts:

- `scripts/emu-status.sh`: screenshot + logcat + UI dump snapshot.
- `scripts/emu-tap.sh <x> <y>`: coordinate tap helper.

## 5. GPU/Shader Diagnostics and Fallbacks

Scan logcat with explicit patterns:

```bash
rg -n \
  "GL_MAX_FRAGMENT_UNIFORM_VECTORS|ImpellerValidationBreak|Could not link shader program|Software rendering is incompatible with Impeller" \
  full.log
```

Interpretation matrix:

| Log Pattern | Likely Cause | Immediate Action |
| --- | --- | --- |
| `GL_MAX_FRAGMENT_UNIFORM_VECTORS` | Emulator uniform limit exceeded | Reduce shader uniforms or split work; verify on physical device |
| `Could not link shader program` | Shader compile/link failure on backend | Retry with clean boot, then compare with physical device |
| `ImpellerValidationBreak` | Engine/backend validation failure | Reproduce on latest Flutter/engine; capture minimal repro |
| `Software rendering is incompatible with Impeller` | No hardware GPU path (common in VMs) | Disable Impeller for emulator pass or move run to physical device |

Fallback policy for agent runs:

1. Retry once after cold emulator boot.
2. Re-run in profile with Impeller (`--profile --enable-impeller`) if not already enabled.
3. If still blocked, run functional pass with software rendering:

```bash
flutter run --enable-software-rendering -d emulator-5554
```

4. Mark result as "environment-limited" and escalate to a physical device for GPU verdict.

## 6. Automation Loop Design

Use existing scripts instead of rewriting orchestration:

- One-shot run: `scripts/headless-emulator-test.sh`
- Long-running loop: `scripts/overnight-emulator-loop.sh`

Example long-run invocation:

```bash
DEVICE=emulator-5554 LOG_DIR=agent_test_logs scripts/overnight-emulator-loop.sh
```

Recommended stop conditions for any autonomous loop:

- Stop after N consecutive identical failures (default: 3).
- Stop after M iterations without net code/test improvement.
- Stop immediately on build-system corruption or unrecoverable emulator boot failures.
- Emit a concise summary per iteration: build status, test status, crash pattern hits, artifact paths.

## 7. Monitoring

```bash
ls -1t agent_test_logs/headless/summary_*.txt | head
tail -f agent_test_logs/headless/test_*.log
```

```bash
# Latest screenshot
xdg-open "$(ls -1t agent_test_logs/headless/screen_*.png | head -n 1)"
```

## 8. CI Example (GitHub Actions)

```yaml
name: Android Emulator Integration Tests
on: [workflow_dispatch]

jobs:
  emulator-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.38.7"
      - name: Run integration tests on emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          target: google_apis
          arch: x86_64
          script: flutter test integration_test/app_test.dart -d emulator-5554 --reporter expanded
```

## 9. Troubleshooting Notes

- `SDK XML versions up to 3 but version 4 was encountered`:
  update Android cmdline-tools to latest in `/usr/lib/android-sdk/cmdline-tools/latest/`.
- `sdkmanager: command not found`:
  call `/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager` directly.
- `Error on ZipFile unknown archive` while downloading images:
  remove corrupted system-image directory and reinstall.
- Boot wait loops that never finish:
  strip `\r` from `getprop` output before string compare.
- If taps fail due to keyboard overlap:
  `adb shell input keyevent KEYCODE_BACK`, then retry tap after ~500 ms.
- `adb devices` shows `emulator-5554 device` but Flutter says no supported device:
  emulator likely flipped offline during/after quickboot restore. Restart adb + emulator cold boot:

```bash
adb kill-server && adb start-server
REUSE_EXISTING=0 WIPE_DATA=1 scripts/headless-emulator-test.sh
```

  and confirm stability with:

```bash
adb devices
adb -s emulator-5554 shell getprop sys.boot_completed
```


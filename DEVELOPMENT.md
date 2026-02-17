# Flutter Fractal Forge - Development Guide

This guide covers setup, testing, and development workflows for Flutter Fractal Forge on Linux (Ubuntu/Debian).

---

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Android SDK Setup](#android-sdk-setup)
3. [Emulator Testing](#emulator-testing)
4. [Desktop Screenshots](#desktop-screenshots)
5. [Troubleshooting](#troubleshooting)

---

## Environment Setup

### Prerequisites

- Ubuntu 24.04+ (or similar Debian-based distro)
- Terminal access with sudo
- Git installed

### Flutter SDK Installation

Download and extract Flutter to your home directory:

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export PATH="$HOME/flutter/bin:$PATH"
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export PATH="/usr/lib/android-sdk/cmdline-tools/latest/bin:$PATH"
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
flutter --version
flutter doctor
```

### Linux Desktop Support

Enable Linux desktop builds:

```bash
flutter config --enable-linux-desktop
flutter doctor
```

Install Linux build dependencies (Ubuntu/Debian):

```bash
sudo apt-get update
sudo apt-get install -y \
  clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev
```

---

## Android SDK Setup

### 1. Install Java / JDK

Flutter Android builds require Java 17+:

```bash
sudo apt update
sudo apt install default-jdk
```

Verify:

```bash
java -version
# Expected: openjdk 21.x or similar
```

### 2. Install Android SDK

**Option A: Via apt (system-wide)**

```bash
sudo apt install android-sdk
```

This installs the SDK to `/usr/lib/android-sdk`.

**Option B: Via Android Studio**

Download Android Studio from https://developer.android.com/studio and install. The SDK will be at `~/Android/Sdk` by default.

### 3. Install Android SDK Command-Line Tools

The `cmdline-tools` component is required by Flutter but **not included** in the apt package.

**Download:**

```bash
cd /tmp
wget "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
```

**Install into the SDK directory:**

```bash
sudo mkdir -p /usr/lib/android-sdk/cmdline-tools
sudo unzip /tmp/commandlinetools-linux-*_latest.zip -d /usr/lib/android-sdk/cmdline-tools/
sudo mv /usr/lib/android-sdk/cmdline-tools/cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest
```

The final path must be: `/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager`

### 4. Fix SDK Directory Permissions

The apt-installed SDK is owned by root. Flutter and sdkmanager need write access:

```bash
sudo chmod -R a+rw /usr/lib/android-sdk
```

### 5. Accept Android Licenses

**Method A: Via sdkmanager (preferred)**

```bash
sdkmanager --licenses --sdk_root=/usr/lib/android-sdk
```

Type `y` to accept each license.

**Method B: Manual file creation (if sdkmanager hangs or fails)**

```bash
mkdir -p /usr/lib/android-sdk/licenses

# Standard SDK license
echo -e "\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > /usr/lib/android-sdk/licenses/android-sdk-license

# ARM license (for NDK)
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > /usr/lib/android-sdk/licenses/android-sdk-arm-dbc-agreement

# NDK/CMake preview license
echo -e "\nd56f5187479451eabf01fb78af6dfcb131a6481e" > /usr/lib/android-sdk/licenses/android-sdk-preview-license
```

### 6. Install Required SDK Components

```bash
sdkmanager --sdk_root=/usr/lib/android-sdk \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "ndk;27.0.12077973"
```

### 7. Verify Setup

```bash
flutter doctor -v
```

All Android-related checks should show green checkmarks:

```
[✓] Android toolchain - develop for Android devices
    • Android SDK at /usr/lib/android-sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: /usr/bin/java
    • Java version OpenJDK Runtime Environment ...
    • All Android licenses accepted.
```

### 8. Build Your App

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle
```

---

## Emulator Testing

### Why Emulator Testing?

Emulator is the primary environment for automated functional testing. Note:
- Emulator is not the source of truth for final GPU shader correctness or performance
- Any shader/performance issue found on emulator should be verified on at least one physical Android device

### Quick Start (Recommended)

Use the repo's one-shot headless runner:

```bash
scripts/headless-emulator-test.sh
```

For flaky/offline emulator sessions, prefer a cold boot (no quickboot snapshot):

```bash
REUSE_EXISTING=0 KEEP_EMULATOR=1 WIPE_DATA=1 scripts/headless-emulator-test.sh
```

**Common variations:**

```bash
# Keep emulator alive after test run
KEEP_EMULATOR=1 scripts/headless-emulator-test.sh

# Override test command
scripts/headless-emulator-test.sh flutter test integration_test/ -d "$DEVICE" --reporter expanded
```

Artifacts are written under `agent_test_logs/headless/` by default.

### Prerequisites

- Linux host with KVM acceleration (`qemu-kvm` installed)
- Flutter SDK available (`$HOME/flutter/bin` or `/home/xel/flutter/bin`)
- Android SDK at `/usr/lib/android-sdk`
- `ANDROID_SDK_ROOT=/usr/lib/android-sdk`
- `adb`, `flutter`, emulator binary, and `sdkmanager` available

**Recommended shell setup:**

```bash
export PATH="$HOME/.local/bin:$HOME/flutter/bin:$PATH"
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
```

### 1. Emulator Setup (One-Time)

**Install image and create AVD:**

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

**Launch emulator:**

```bash
# Interactive
/usr/lib/android-sdk/emulator/emulator -avd fractal_test -no-audio -gpu swiftshader_indirect

# Headless
/usr/lib/android-sdk/emulator/emulator -avd fractal_test -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect
```

**Wait for full boot:**

```bash
adb wait-for-device
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
  sleep 3
done
```

### 2. Run Modes for Testing

**Debug smoke run:**

```bash
flutter run -d emulator-5554
```

**Shader-focused run (profile + Impeller):**

```bash
flutter run --profile --enable-impeller -d emulator-5554
```

**Attach for live diagnostics:**

```bash
flutter attach -d emulator-5554
```

Note: this repo currently sets `io.flutter.embedding.android.EnableImpeller=false` in `android/app/src/main/AndroidManifest.xml`; use runtime flags for targeted Impeller passes.

### 3. Integration Test Commands

**Single target:**

```bash
flutter test integration_test/app_test.dart -d emulator-5554 --reporter expanded
```

**Whole integration suite:**

```bash
flutter test integration_test/ -d emulator-5554 --reporter expanded
```

**Useful GPU-focused targets in this repo:**

- `integration_test/render_validation_test.dart`
- `integration_test/perf_smoke_test.dart`
- `integration_test/shader_benchmark_test.dart`

**AR permission path checks:**

```bash
adb shell pm revoke com.fractals.flutter_fractals android.permission.CAMERA
adb shell pm grant com.fractals.flutter_fractals android.permission.CAMERA
```

### 4. Deterministic Artifact Capture

**Inside `integration_test`, settle frames before screenshot:**

```dart
final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    as IntegrationTestWidgetsFlutterBinding;

await tester.pumpAndSettle();
await binding.takeScreenshot('viewer_loaded');
```

**ADB screenshot:**

```bash
adb -s emulator-5554 shell screencap -p /sdcard/screen.png
adb -s emulator-5554 pull /sdcard/screen.png ./screenshots/
```

**Log capture:**

```bash
# Flutter logs
adb -s emulator-5554 logcat -d -s flutter > flutter.log

# Full timestamped logs
adb -s emulator-5554 logcat -d -v time > full.log
```

**In-app debug logs:**

```bash
adb shell run-as com.fractals.flutter_fractals \
  cat app_flutter/debug_logs/session_*.log
```

**Helper scripts:**

- `scripts/emu-status.sh`: screenshot + logcat + UI dump snapshot
- `scripts/emu-tap.sh <x> <y>`: coordinate tap helper

### 5. GPU/Shader Diagnostics and Fallbacks

**Scan logcat with explicit patterns:**

```bash
rg -n \
  "GL_MAX_FRAGMENT_UNIFORM_VECTORS|ImpellerValidationBreak|Could not link shader program|Software rendering is incompatible with Impeller" \
  full.log
```

**Interpretation matrix:**

| Log Pattern | Likely Cause | Immediate Action |
| --- | --- | --- |
| `GL_MAX_FRAGMENT_UNIFORM_VECTORS` | Emulator uniform limit exceeded | Reduce shader uniforms or split work; verify on physical device |
| `Could not link shader program` | Shader compile/link failure on backend | Retry with clean boot, then compare with physical device |
| `ImpellerValidationBreak` | Engine/backend validation failure | Reproduce on latest Flutter/engine; capture minimal repro |
| `Software rendering is incompatible with Impeller` | No hardware GPU path (common in VMs) | Disable Impeller for emulator pass or move run to physical device |

**Fallback policy for agent runs:**

1. Retry once after cold emulator boot
2. Re-run in profile with Impeller (`--profile --enable-impeller`) if not already enabled
3. If still blocked, run functional pass with software rendering:
   ```bash
   flutter run --enable-software-rendering -d emulator-5554
   ```
4. Mark result as "environment-limited" and escalate to a physical device for GPU verdict

### 6. Monitoring

```bash
ls -1t agent_test_logs/headless/summary_*.txt | head
tail -f agent_test_logs/headless/test_*.log
```

```bash
# Latest screenshot
xdg-open "$(ls -1t agent_test_logs/headless/screen_*.png | head -n 1)"
```

---

## Desktop Screenshots

### Why Desktop Screenshots?

This project can generate store/README screenshots **using Flutter Desktop** (Linux) via `integration_test`, so you don't depend on Android system image downloads.

**Benefits:**
- ✅ No AVD creation
- ✅ No `sdkmanager` / system-image zip corruption issues
- ✅ Deterministic size (fixed 1080×1920 surface)
- ✅ Works headless in CI with `xvfb-run`

### 1. One-time setup (Linux)

1. Install Flutter SDK and add it to your `PATH`
2. Enable Linux desktop support:

```bash
flutter config --enable-linux-desktop
flutter doctor
```

If Flutter asks for Linux build deps, install them (Ubuntu/Debian typically):

```bash
sudo apt-get update
sudo apt-get install -y \
  clang cmake ninja-build pkg-config libgtk-3-dev \
  liblzma-dev libstdc++-12-dev
```

### 2. Run screenshots locally (with desktop session)

```bash
./scripts/desktop-screenshots.sh
```

This runs `integration_test/screenshots_test.dart` on the `linux` device and copies `.png` files into:

```
./screenshots/
```

### 3. Run screenshots headless (CI/server)

If `xvfb-run` is installed, the script automatically uses it.

To install:

```bash
sudo apt-get install -y xvfb
```

Then run:

```bash
./scripts/desktop-screenshots.sh
```

### 4. What gets captured

See `integration_test/screenshots_test.dart`.

Currently captured:
- `01_catalog`
- `02_viewer_mandelbulb`
- `03_viewer_mandelbrot`
- `04_viewer_julia`
- `05_viewer_burning_ship`

### Notes / gotchas

- The fractal viewer is shader/animation driven; `pumpAndSettle()` may never finish. The screenshot tests use a fixed `pump(Duration(seconds: 2))` instead.
- Screenshot output location under `build/` varies a bit by Flutter version; the script searches `build/` for PNGs and copies them to `./screenshots/`.
- For Play Store "phone" screenshots, a 1080×1920 surface is a common baseline.

### Optional: Golden tests (visual regression)

If you want pixel-diff regression tests, you can add widget golden tests using `matchesGoldenFile()` or a toolkit like `golden_toolkit`.

For this app, goldens may be harder to keep stable because of GPU shader output and continuous animation; desktop integration screenshots are usually more robust for marketing/store assets.

---

## Troubleshooting

### Android SDK Issues

**`cmdline-tools component is missing`**

Flutter requires the cmdline-tools even if the rest of the SDK is installed. See Android SDK Setup step 3.

**`Android license status unknown`**

Run `sdkmanager --licenses` or create license files manually (see Android SDK Setup step 5 Method B).

**`Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'`**

Usually a missing or discontinued dependency in `pubspec.yaml`. Check that all packages still exist on pub.dev. Notably, `ffmpeg_kit_flutter_min_gpl` was discontinued in 2024 and its Maven artifacts were removed — if your project uses it, you must remove or replace it.

**Permission denied errors during build**

```bash
sudo chmod -R a+rw /usr/lib/android-sdk
```

**Flutter SDK not on PATH**

Add to `~/.bashrc`:

```bash
export PATH="$HOME/flutter/bin:$PATH"
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export PATH="/usr/lib/android-sdk/cmdline-tools/latest/bin:$PATH"
```

Then `source ~/.bashrc`.

**Important:** `ANDROID_SDK_ROOT` must be set or Flutter won't find the sdkmanager and will report "Android license status unknown" even after accepting licenses.

### Linux Desktop Build Issues

**`lld` linker not found**

If building for Linux desktop and `lld` is not installed:

```bash
# Option A: Install lld
sudo apt install lld

# Option B: Wrapper script workaround
mkdir -p ~/.local/bin
# Create a clang++ wrapper that doesn't require lld
# and symlink ld/ld.lld in the same directory
```

See project memory for specific workaround details.

### Emulator Issues

**`SDK XML versions up to 3 but version 4 was encountered`**

Update Android cmdline-tools to latest in `/usr/lib/android-sdk/cmdline-tools/latest/`.

**`sdkmanager: command not found`**

Call `/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager` directly.

**`Error on ZipFile unknown archive` while downloading images**

Remove corrupted system-image directory and reinstall.

**Boot wait loops that never finish**

Strip `\r` from `getprop` output before string compare.

**Taps fail due to keyboard overlap**

```bash
adb shell input keyevent KEYCODE_BACK
```

Then retry tap after ~500 ms.

**`adb devices` shows `emulator-5554 device` but Flutter says no supported device**

Emulator likely flipped offline during/after quickboot restore. Restart adb + emulator cold boot:

```bash
adb kill-server && adb start-server
REUSE_EXISTING=0 WIPE_DATA=1 scripts/headless-emulator-test.sh
```

Confirm stability with:

```bash
adb devices
adb -s emulator-5554 shell getprop sys.boot_completed
```

---

## CI Example (GitHub Actions)

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

---

*This guide is specific to Flutter Fractal Forge development on Linux (Ubuntu/Debian).*
*Last updated: 2026-02-16*

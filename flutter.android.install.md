# Flutter + Android SDK Setup on Linux (Ubuntu/Debian)

Guide for preparing a Linux PC to build Flutter apps for Android.

## Prerequisites

- Ubuntu 24.04+ (or similar Debian-based distro)
- Terminal access with sudo

## 1. Install Java / JDK

Flutter Android builds require Java 17+.

```bash
sudo apt update
sudo apt install default-jdk
```

Verify:

```bash
java -version
# Expected: openjdk 21.x or similar
```

## 2. Install Flutter SDK

Download and extract Flutter to your home directory:

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export PATH="$HOME/flutter/bin:$PATH"
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

## 3. Install Android SDK

### Option A: Via apt (system-wide)

```bash
sudo apt install android-sdk
```

This installs the SDK to `/usr/lib/android-sdk`.

Set the environment variable in your shell profile:

```bash
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
```

### Option B: Via Android Studio

Download Android Studio from https://developer.android.com/studio and install. The SDK will be at `~/Android/Sdk` by default.

## 4. Install Android SDK Command-Line Tools

The `cmdline-tools` component is required by Flutter but **not included** in the apt package.

### Download

Go to https://developer.android.com/studio#command-line-tools-only and download the Linux zip.

Or via terminal:

```bash
cd /tmp
wget "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
```

### Install into the SDK directory

```bash
sudo mkdir -p /usr/lib/android-sdk/cmdline-tools
sudo unzip /tmp/commandlinetools-linux-*_latest.zip -d /usr/lib/android-sdk/cmdline-tools/
sudo mv /usr/lib/android-sdk/cmdline-tools/cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest
```

The final path must be: `/usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager`

### Add to PATH

```bash
export PATH="/usr/lib/android-sdk/cmdline-tools/latest/bin:$PATH"
```

## 5. Fix SDK Directory Permissions

The apt-installed SDK is owned by root. Flutter and sdkmanager need write access:

```bash
sudo chmod -R a+rw /usr/lib/android-sdk
```

## 6. Accept Android Licenses

### Method A: Via sdkmanager (preferred)

```bash
sdkmanager --licenses --sdk_root=/usr/lib/android-sdk
```

Type `y` to accept each license.

### Method B: Manual file creation (if sdkmanager hangs or fails)

If `sdkmanager --licenses` doesn't work, create the license files manually:

```bash
mkdir -p /usr/lib/android-sdk/licenses

# Standard SDK license
echo -e "\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > /usr/lib/android-sdk/licenses/android-sdk-license

# ARM license (for NDK)
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > /usr/lib/android-sdk/licenses/android-sdk-arm-dbc-agreement

# NDK/CMake preview license
echo -e "\nd56f5187479451eabf01fb78af6dfcb131a6481e" > /usr/lib/android-sdk/licenses/android-sdk-preview-license
```

## 7. Install Required SDK Components

```bash
sdkmanager --sdk_root=/usr/lib/android-sdk \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "ndk;27.0.12077973"
```

## 8. Verify Setup

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

## 9. Build Your App

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle
```

## Troubleshooting

### `cmdline-tools component is missing`

Flutter requires the cmdline-tools even if the rest of the SDK is installed. See step 4 above.

### `Android license status unknown`

Run `sdkmanager --licenses` or create license files manually (step 6 Method B).

### `Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'`

Usually a missing or discontinued dependency in `pubspec.yaml`. Check that all packages still exist on pub.dev. Notably, `ffmpeg_kit_flutter_min_gpl` was discontinued in 2024 and its Maven artifacts were removed — if your project uses it, you must remove or replace it.

### Permission denied errors during build

```bash
sudo chmod -R a+rw /usr/lib/android-sdk
```

### `lld` linker not found (Linux desktop builds)

If building for Linux desktop and `lld` is not installed:

```bash
# Option A: Install lld
sudo apt install lld

# Option B: Wrapper script workaround
mkdir -p ~/.local/bin
# Create a clang++ wrapper that doesn't require lld
# and symlink ld/ld.lld in the same directory
```

### Flutter SDK not on PATH

Add to `~/.bashrc`:

```bash
export PATH="$HOME/flutter/bin:$PATH"
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export PATH="/usr/lib/android-sdk/cmdline-tools/latest/bin:$PATH"
```

Then `source ~/.bashrc`.

# Desktop Screenshots Workflow (No Android Emulator)

This project can generate store/README screenshots **using Flutter Desktop** (Linux) via `integration_test`, so you don't depend on Android system image downloads.

## Why this approach

- ✅ No AVD creation
- ✅ No `sdkmanager` / system-image zip corruption issues
- ✅ Deterministic size (fixed 1080×1920 surface)
- ✅ Works headless in CI with `xvfb-run`

## 1) One-time setup (Linux)

1. Install Flutter SDK and add it to your `PATH`.
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

## 2) Run screenshots locally (with desktop session)

```bash
./scripts/desktop-screenshots.sh
```

This runs `integration_test/screenshots_test.dart` on the `linux` device and copies `.png` files into:

```
./screenshots/
```

## 3) Run screenshots headless (CI/server)

If `xvfb-run` is installed, the script automatically uses it.

To install:

```bash
sudo apt-get install -y xvfb
```

Then run:

```bash
./scripts/desktop-screenshots.sh
```

## 4) What gets captured

See `integration_test/screenshots_test.dart`.

Currently captured:

- `01_catalog`
- `02_viewer_mandelbulb`
- `03_viewer_mandelbrot`
- `04_viewer_julia`
- `05_viewer_burning_ship`

## Notes / gotchas

- The fractal viewer is shader/animation driven; `pumpAndSettle()` may never finish. The screenshot tests use a fixed `pump(Duration(seconds: 2))` instead.
- Screenshot output location under `build/` varies a bit by Flutter version; the script searches `build/` for PNGs and copies them to `./screenshots/`.
- For Play Store "phone" screenshots, a 1080×1920 surface is a common baseline.

## Optional: Golden tests (visual regression)

If you want pixel-diff regression tests, you can add widget golden tests using `matchesGoldenFile()` or a toolkit like `golden_toolkit`.

For this app, goldens may be harder to keep stable because of GPU shader output and continuous animation; desktop integration screenshots are usually more robust for marketing/store assets.

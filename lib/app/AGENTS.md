<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-29 -->

# app

## Purpose
Application composition layer for Flutter Fractal Forge. Owns the root `FlutterFractalsApp`, startup service initialization, and developer diagnostic boot-mode widgets.

## Files

| File | Description |
|------|-------------|
| `flutter_fractals_app.dart` | Root app widget, provider wiring, MaterialApp shell, splash/onboarding/home bootstrap |
| `startup.dart` | Deferred startup widget that initializes stores/services after an immediate loading UI |
| `diagnostic_apps.dart` | SAFE_MODE and BOOT_STEP diagnostic apps used by `main.dart` |

## Notes
- Keep `main.dart` as the public entrypoint/facade; it re-exports `FlutterFractalsApp` for existing tests/imports.
- Diagnostic apps intentionally use hardcoded English strings because localization is not initialized in those boot paths.

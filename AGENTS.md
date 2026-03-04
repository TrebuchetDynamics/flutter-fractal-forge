<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# Flutter Fractal Forge

## Purpose

## Key Files

| File | Description |
|------|-------------|
| `lib/main.dart` | App entry point, service initialization, root widget with Provider setup |
| `pubspec.yaml` | Dependencies and shader/asset declarations |
| `l10n.yaml` | Localization configuration |
| `analysis_options.yaml` | Dart analyzer rules |
| `PRD.md` | Product requirements document |
| `TODO.md` | Remaining tasks and features |
| `PERFORMANCE.md` | Performance optimization notes |
| `SHADER_OPTIMIZATIONS.md` | GPU shader optimization strategies |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `lib/` | Application source code - models, modules, services, features (see `lib/AGENTS.md`) |
| `shaders/` | 220+ GLSL fragment shaders for GPU fractal rendering (see `shaders/AGENTS.md`) |
| `fractals-library/` | 200 fractal definitions organized by mathematical category (see `fractals-library/AGENTS.md`) |
| `test/` | Unit and widget tests (see `test/AGENTS.md`) |
| `integration_test/` | Integration and screenshot tests (see `integration_test/AGENTS.md`) |
| `assets/` | App icons and 250+ catalog thumbnail images (see `assets/AGENTS.md`) |
| `scripts/` | Shell scripts for screenshots, emulator automation (see `scripts/AGENTS.md`) |
| `android/` | Android platform configuration |
| `ios/` | iOS platform configuration |
| `macos/` | macOS platform configuration |
| `windows/` | Windows platform configuration |
| `linux/` | Linux platform configuration |
| `web/` | Web platform configuration |

## For AI Agents

### Architecture Overview

```
State Management: Provider + ChangeNotifier (FractalController)
Rendering: GLSL fragment shaders via Flutter's FragmentShader API
Module System: Declarative EscapeTimeConfig catalog + custom builder functions
Navigation: HomeScreen -> Catalog -> Viewer (with FractalController per tab)
```

### Working In This Directory
- Build with: `PATH="/home/xel/.local/bin:$PATH" /home/xel/flutter/bin/flutter run -d linux`
- Dart SDK 3.10.7, Flutter desktop (Linux primary)
- `lld` linker workaround: shell script at `~/.local/bin/clang++`
- Provider is used for DI; FractalController is the primary state holder
- Most fractals use the escape-time builder pattern (declarative config + shader)

### Key Patterns
- **Module system**: `FractalModule` defines a fractal type (id, shader, params, presets, uniform setter). Registered in `ModuleRegistry`
- **Escape-time catalog**: Standard fractals defined declaratively in `escape_time_catalog.dart`; custom fractals (Julia, Phoenix, Mandelbulb) have dedicated builders
- **Shader uniforms**: Each module's `setUniforms` callback maps Dart params to GLSL uniforms
- **Safe/boot modes**: `SAFE_MODE` and `BOOT_STEP` environment vars for incremental debugging

### Testing Requirements
- Run unit tests: `/home/xel/flutter/bin/flutter test`
- Run integration tests: `/home/xel/flutter/bin/flutter test integration_test/`
- Widget tests use `pumpWidget` with mock stores/services

### Common Gotchas
- Class fields typed as `Object` do NOT get type-promoted in Dart; assign to local variable first
- `image` package v4.x API changes: `compositeImage` (not `copyInto`), frame list for GIF
- Shader assets must be registered in `pubspec.yaml` under `flutter.shaders`

## Dependencies

### External
- `provider` ^6.1.2 - State management
- `vector_math` ^2.1.4 - Math for 3D transforms
- `image` ^4.0.0 - Image encoding/export
- `shared_preferences` ^2.2.0 - Local persistence
- `camera` ^0.10.6 - overlay camera feed
- `path_provider` ^2.1.0 - File system paths
- `share_plus` ^7.0.0 - Share/export
- `permission_handler` ^11.0.0 - Runtime permissions

<!-- MANUAL: -->

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# test

## Purpose
Unit tests and widget tests for the Flutter Fractal Forge application. Tests cover models, services, controllers, UI widgets, and rendering behavior. Uses Flutter's built-in test framework with `flutter_test`.

## Key Files

| File | Description |
|------|-------------|
| `widget_test.dart` | Basic app widget smoke test |
| `fractal_params_test.dart` | FractalParams model serialization and validation |
| `fractal_preset_json_test.dart` | Preset JSON round-trip serialization |
| `fractal_controller_behavior_test.dart` | FractalController state management behavior |
| `fractal_controller_clamp_test.dart` | Parameter clamping and validation |
| `fractal_controller_reset_session_test.dart` | Session reset logic |
| `fractal_renderer_widget_test.dart` | Renderer widget lifecycle and error handling |
| `fractal_renderer_gesture_test.dart` | Gesture input handling (pan, zoom, rotate) |
| `fractal_render_audit_test.dart` | Render correctness audit across all modules |
| `home_screen_widget_test.dart` | HomeScreen navigation and tab behavior |
| `fractal_catalog_screen_widget_test.dart` | Catalog browsing and search |
| `export_service_test.dart` | Image export functionality |
| `export_options_test.dart` | Export options model tests |
| `preset_sheet_widget_test.dart` | Preset UI panel tests |
| `preset_sheet_comprehensive_test.dart` | Comprehensive preset selection/save flows |
| `accessibility_test.dart` | Accessibility compliance tests |
| `crash_reporter_test.dart` | Crash reporting service tests |
| `deep_link_service_test.dart` | Deep link parsing and handling |
| `performance_service_test.dart` | Performance monitoring tests |
| `renderer_backend_policy_test.dart` | GPU vs CPU backend selection logic |
| `catalog_repository_test.dart` | Catalog data layer tests |
| `catalog_thumbnail_audit_test.dart` | Thumbnail existence/integrity audit |
| `generate_catalog_thumbnails_test.dart` | GPU thumbnail generation test |
| `shader_benchmark_test.dart` | Shader performance benchmarks |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `core/shaders/` | Shader uniform schema tests |
| `helpers/` | Test utilities and helpers (accessibility_test_helper) |

## For AI Agents

### Working In This Directory
- Run all tests: `/home/xel/flutter/bin/flutter test`
- Run single test: `/home/xel/flutter/bin/flutter test test/<filename>.dart`
- Tests use mock stores created inline (no shared mock files)
- Widget tests wrap in `MaterialApp` + required providers

### Testing Patterns
- `pumpWidget` with `FlutterFractalsApp(...)` for full-app tests
- `context.read<ModuleRegistry>()` needs a Provider ancestor in test tree
- FractalController tests create controller directly with `ModuleRegistry()`
- Some tests use `FLUTTER_TEST` env var for conditional behavior

### Common Patterns
- Tests follow `*_test.dart` naming convention
- Widget tests use `_widget_test.dart` suffix for UI component tests
- Comprehensive tests use `_comprehensive_test.dart` suffix for thorough coverage

## Dependencies

### Internal
- `lib/` - All application source code under test

### External
- `flutter_test` - Testing framework
- `integration_test` - Integration test support

<!-- MANUAL: -->

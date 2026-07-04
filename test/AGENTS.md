<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# test

## Purpose
Unit tests and widget tests for the Flutter Fractal Forge application. Tests cover models, services, controllers, UI widgets, and rendering behavior. Uses Flutter's built-in test framework with `flutter_test`.

## Key Files

| File | Description |
|------|-------------|
| `widget_test.dart` | Basic app widget smoke test |
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
| `catalog_thumbnail_audit_test.dart` | Verifies static catalog thumbnail bundle stays removed |
| `generate_catalog_thumbnails_test.dart` | Legacy/manual GPU thumbnail generation test |
| `shader_benchmark_test.dart` | Shader performance benchmarks |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `helpers/` | Test utilities and helpers (accessibility_test_helper) |

## For AI Agents

### Working In This Directory
- Run all tests: `flutter test`
- Run single test: `flutter test test/<filename>.dart`
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

<!-- karpathy-guidelines:start -->
## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions before implementing; ask when uncertainty would change the solution.
- Surface multiple interpretations and tradeoffs instead of silently picking one.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.
<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->
## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/test`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

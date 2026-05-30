<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# services

## Purpose
Application services providing business logic, persistence, and platform integration. Services are initialized at app startup and provided to the widget tree via Provider. Most are stateless or use ChangeNotifier for reactive updates.

## Key Files

| File | Description |
|------|-------------|
| `shader_service.dart` | Loads and caches GLSL fragment shaders from assets |
| `preset_store.dart` | Persists user presets to SharedPreferences |
| `palette_store.dart` | Stores custom color palettes |
| `palette_service.dart` | Palette management and selection logic |
| `history_store.dart` | Persists exploration history entries |
| `export_service.dart` | PNG/image export with resolution scaling and transparency |
| `video_export_service.dart` | Video/GIF export pipeline |
| `batch_export_service.dart` | Batch export of multiple fractals |
| `accessibility_service.dart` | Accessibility settings (high contrast, reduced motion) as ChangeNotifier |
| `onboarding_service.dart` | First-launch onboarding state tracking |
| `deep_link_service.dart` | Parse and handle incoming deep links |
| `performance_service.dart` | FPS monitoring and performance metrics |
| `crash_reporter.dart` | Local-only crash/error recording |
| `haptic_service.dart` | Haptic feedback triggers |
| `wallpaper_service.dart` | Set fractal as device wallpaper |
| `animation_controller_service.dart` | Manages parameter auto-animation (play/pause/speed/easing) |
| `exploration_stats_service.dart` | Tracks exploration statistics |
| `debug_runner_service.dart` | Debug mode test runner |
| `test_logger.dart` | Test instrumentation logger |
| `test_screenshot_service.dart` | Screenshot capture for automated tests |

## For AI Agents

### Working In This Directory
- Services are initialized async in `main.dart` before `runApp()`
- `create()` factory pattern: `await PresetStore.create()` for async initialization
- Services provided via `Provider<T>.value(value: service)` in root widget
- `AccessibilityService` uses `ChangeNotifier` - consume with `Consumer<AccessibilityService>`
- Export services need `import 'package:flutter/rendering.dart'` for `RenderRepaintBoundary`

### Testing Requirements
- Each service has a dedicated test file in `test/`
- Mock services by creating test instances (no dependency injection framework)

### Common Patterns
- Async factory constructor: `static Future<T> create() async { ... }`
- SharedPreferences-backed persistence for stores
- ChangeNotifier for reactive state (accessibility, history)

## Dependencies

### External
- `shared_preferences` - Local key-value persistence
- `path_provider` - File system paths
- `share_plus` - Share/export
- `image` - Image encoding

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/core/services`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

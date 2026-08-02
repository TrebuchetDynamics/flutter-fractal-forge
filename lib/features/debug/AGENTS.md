<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# debug

## Purpose

Developer diagnostics for real-time performance, shader rendering, and app logs.

## Key Files

| File                       | Description                                                          |
| -------------------------- | -------------------------------------------------------------------- |
| `log_viewer_screen.dart`   | `LogViewerScreen` - filterable app log viewer with export support    |
| `performance_overlay.dart` | `FractalPerformanceOverlay` - real-time FPS and frame-time metrics   |
| `shader_lab_screen.dart`   | `ShaderLabScreen` - isolated Flutter and fragment-shader diagnostics |

## For AI Agents

### Working In This Directory

- Shader Lab isolates solid-color, gradient, and runtime fragment-shader rendering
- Performance overlay uses `PerformanceService` for metrics
- Log viewer reads from `AppLogger` and exports through `ExportService`

### Testing Requirements

- `test/diagnostics/log_viewer_screen_test.dart`
- `test/shaders/shader_lab_screen_test.dart`
- `test/shaders/shader_lab_screen_a11y_test.dart`

## Dependencies

### Internal

- `core/services/diagnostics/performance_service.dart` - Performance metrics
- `core/services/diagnostics/app_logger_service.dart` - App log stream
- `core/services/export/export_service.dart` - Log export

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/debug`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.

<!-- karpathy-project-adjustment:end -->

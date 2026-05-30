<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# export

## Purpose
Image and video export UI dialogs. Provides resolution selection, format options, transparency toggle, and batch export functionality.

## Key Files

| File | Description |
|------|-------------|
| `export_options_sheet.dart` | `ExportOptionsSheet` - bottom sheet for single-image export (resolution, transparency, format) |
| `video_export_sheet.dart` | `VideoExportSheet` - bottom sheet for video/GIF export (duration, FPS, resolution) |
| `batch_export_dialog.dart` | `BatchExportDialog` - dialog for exporting multiple fractals at once |

## For AI Agents

### Working In This Directory
- Export uses `RenderRepaintBoundary` to capture the rendered fractal
- Transparent PNG export sets alpha=0 for background pixels
- Video export uses the `image` package v4.x API (frame list + `addFrame`/`encodeGif`)
- Batch export iterates through selected modules

### Testing Requirements
- `test/export_options_sheet_widget_test.dart`
- `test/export_service_test.dart`, `test/export_options_test.dart`

## Dependencies

### Internal
- `core/services/export_service.dart` - Export business logic
- `core/services/video_export_service.dart` - Video encoding
- `core/services/batch_export_service.dart` - Multi-fractal export
- `core/models/export_options.dart` - Export configuration model

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/export`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

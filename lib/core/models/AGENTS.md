<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# models

## Purpose
Immutable data classes representing the application's domain model. These define the shape of fractal parameters, presets, view state, and export configuration.

## Key Files

| File | Description |
|------|-------------|
| `fractal_parameter.dart` | `FractalParameter` - defines a single configurable parameter (type, range, step, default) with `FractalParamType` enum |
| `fractal_preset.dart` | `FractalPreset` - named snapshot of parameters + view state + palette for save/restore |
| `fractal_view_state.dart` | `FractalViewState` - pan offset, zoom level, rotation angles for the viewport |
| `fractal_palette.dart` | `FractalPalette` - color palette definition for fractal coloring |
| `export_options.dart` | `ExportOptions` - image export configuration (resolution, format, transparency) |
| `video_export_options.dart` | `VideoExportOptions` - video/GIF export settings (duration, FPS, resolution) |
| `exploration_stats.dart` | `ExplorationStats` - statistics tracking for exploration sessions |
| `wallpaper_options.dart` | `WallpaperOptions` - wallpaper export settings (placement, scaling) |

## For AI Agents

### Working In This Directory
- Models are immutable (`@immutable` annotation) data containers
- Fields typed as `Object` do NOT get type-promoted in Dart - use local variable first: `final v = value; if (v is num) v.toDouble()`
- Presets are JSON-serializable for persistence via `SharedPreferences`
- `FractalParameter` supports types: float, integer, boolean, enumeration

### Common Patterns
- Constructor-based immutability with `const` constructors where possible
- `copyWith` methods for creating modified copies
- JSON serialization via `toJson()`/`fromJson()` factory constructors

## Dependencies

### External
- `equatable` - Value equality for model comparison
- `vector_math` - Vector types for view state

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/core/models`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

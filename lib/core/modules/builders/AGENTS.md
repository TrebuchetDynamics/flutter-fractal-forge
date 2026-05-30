<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# builders

## Purpose
Declarative escape-time fractal builder system. Provides a pattern where standard escape-time fractals are defined as simple config entries (shader path + params + presets) rather than full custom builder functions. The builder handles uniform setting, parameter creation, and module construction automatically.

## Key Files

| File | Description |
|------|-------------|
| `escape_time_builder.dart` | `buildEscapeTimeModule()` - creates a `FractalModule` from an `EscapeTimeConfig`. Handles standard uniform layout (resolution, center, zoom, iterations, bailout, colorScheme, time) |
| `escape_time_catalog.dart` | `buildEscapeTimeCatalogModules()` - master list of all declarative fractal configs. Each `EscapeTimeConfig` entry = one fractal |

## For AI Agents

### Working In This Directory
- To add a new escape-time fractal:
  1. Write the `.frag` shader following standard uniform layout
  2. Add an `EscapeTimeConfig(...)` entry to `escape_time_catalog.dart`
  3. Register shader in `pubspec.yaml` under `flutter.shaders`
  4. Done - no Dart module code needed!
- `EscapeTimeConfig` fields: id, shaderAsset, displayName, category, default iterations/bailout, presets
- The builder auto-generates: parameter list, uniform setter, default preset

### Standard Uniform Layout
Shaders built via this system MUST use this uniform order:
1. `uResolution` (vec2) - canvas pixel size
2. `uCenter` (vec2) - complex plane center
3. `uZoom` (float) - zoom level
4. `uIterations` (float) - max iterations
5. `uBailout` (float) - escape radius
6. `uColorScheme` (float) - palette index
7. `uTime` (float) - animation time

### Testing Requirements
- Catalog tested via `test/module_registry_widget_test.dart`
- Render audit in `test/fractal_render_audit_test.dart`

## Dependencies

### Internal
- `../fractal_module.dart` - FractalModule, FractalRenderState
- `../common_params.dart` - Shared parameter builders
- `../../models/` - FractalParameter, FractalPreset

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/core/modules/builders`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

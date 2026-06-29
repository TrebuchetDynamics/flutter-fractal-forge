<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# core

## Purpose
Foundation layer of the application. Contains data models, fractal module definitions, application services, theming, and shared widgets. Everything in `core/` is feature-agnostic and can be used by any feature screen.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `models/` | Data classes: FractalPreset, FractalViewState, ExportOptions, etc. (see `models/AGENTS.md`) |
| `modules/` | Fractal module system: FractalModule, ModuleRegistry, escape-time catalog, custom builders (see `modules/AGENTS.md`) |
| `services/` | Application services: export, presets, history, accessibility, rendering support, etc. (see `services/AGENTS.md`) |
| `shaders/` | Reserved for Dart-side shader helpers; active uniform slot contracts live under `modules/builders/` (see `shaders/AGENTS.md`) |
| `theme/` | App theme: colors, text styles, dark/high-contrast themes (see `theme/AGENTS.md`) |
| `widgets/` | Shared widgets: accessibility, animations, error boundary (see `widgets/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- `core/` is the dependency foundation - features depend on core, never the reverse
- Models are immutable data classes (many use `@immutable` annotation)
- Services are initialized at app startup and provided via Provider
- The module system is the heart of fractal rendering configuration

### Architecture Rules
- No feature-specific UI code belongs in `core/`
- Services should be stateless or use `ChangeNotifier` for reactive state
- Models should be serializable for persistence/deep linking

## Dependencies

### External
- `provider` - State management
- `vector_math` - 3D math operations
- `image` - Image encoding
- `shared_preferences` - Local persistence

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/core`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

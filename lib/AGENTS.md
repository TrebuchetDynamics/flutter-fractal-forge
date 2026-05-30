<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# lib

## Purpose
Main application source code for Flutter Fractal Forge. Organized into core infrastructure (models, modules, services), feature screens, and shared utilities. Uses Provider for state management with FractalController as the primary state holder.

## Key Files

| File | Description |
|------|-------------|
| `main.dart` | App entry point/facade; configures error handling, boot-mode selection, and re-exports `FlutterFractalsApp` for compatibility |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `app/` | Application composition layer: root app widget, startup flow, diagnostic boot apps (see `app/AGENTS.md`) |
| `core/` | Foundation layer: data models, fractal modules, services, theme, widgets (see `core/AGENTS.md`) |
| `features/` | Feature screens and UI components organized by domain (see `features/AGENTS.md`) |
| `shared/` | Cross-cutting utilities shared across features (see `shared/AGENTS.md`) |
| `l10n/` | Generated localization files for EN + ES (see `l10n/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Entry point is `main.dart`; app composition and Provider setup live under `app/`
- FractalController is created in HomeScreen, NOT at root
- All fractal modules are registered via `ModuleRegistry` at startup
- Services (PresetStore, HistoryStore, etc.) are initialized async before `runApp`

### Architecture Flow
```
main.dart -> FlutterFractalsApp (providers) -> HomeScreen
  -> FractalCatalogScreen (browse fractals)
  -> FractalViewerScreen (render + interact)
```

### Testing Requirements
- Widget tests need mock stores: `PresetStore`, `HistoryStore`
- Use `FlutterFractalsApp` constructor with test parameters for integration tests

### Common Patterns
- Provider-based DI: services provided at root, consumed via `context.read<T>()`
- ChangeNotifier pattern: FractalController notifies listeners on state changes
- Safe mode flags: `SAFE_MODE` and `BOOT_STEP` env vars for incremental debugging

## Dependencies

### External
- `provider` - State management and DI
- `flutter_localizations` - i18n support

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

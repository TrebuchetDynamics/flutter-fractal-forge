<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# features

## Purpose
Feature-level screens and UI components, organized by domain. Each subdirectory represents a distinct feature area of the application. Features consume `core/` services and models but should not depend on each other directly.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `auto_explore/` | Autonomous fractal exploration with auto-animation (see `auto_explore/AGENTS.md`) |
| `catalog/` | Fractal catalog browser with search and thumbnails (see `catalog/AGENTS.md`) |
| `controls/` | Parameter control panel (sliders, toggles) (see `controls/AGENTS.md`) |
| `debug/` | Debug overlays for performance, shader, and rendering diagnostics (see `debug/AGENTS.md`) |
| `export/` | Image/video export dialogs and options (see `export/AGENTS.md`) |
| `history/` | Exploration history tracking and browsing (see `history/AGENTS.md`) |
| `home/` | Main home screen with tab navigation (see `home/AGENTS.md`) |
| `minimap/` | Fractal minimap overview widget (see `minimap/AGENTS.md`) |
| `onboarding/` | First-launch onboarding flow (see `onboarding/AGENTS.md`) |
| `presets/` | Preset selection and management panel (see `presets/AGENTS.md`) |
| `renderer/` | Core fractal rendering engine with GPU/CPU backends (see `renderer/AGENTS.md`) |
| `settings/` | Accessibility settings screen (see `settings/AGENTS.md`) |
| `viewer/` | Full fractal viewer screen with controls integration (see `viewer/AGENTS.md`) |
| `wallpaper/` | Wallpaper export options (see `wallpaper/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each feature is self-contained in its own directory
- Features access shared state via Provider (FractalController, services)
- Navigation flow: HomeScreen -> CatalogScreen -> ViewerScreen
- FractalController is scoped per-tab (created in HomeScreen), not global

### Architecture Rules
- Features depend on `core/` but NOT on each other
- Cross-feature communication goes through Provider/services
- Each feature directory typically has 1-3 Dart files
- UI-heavy features may have widget extraction files

## Dependencies

### Internal
- `core/models/` - Data classes
- `core/modules/` - Fractal module definitions
- `core/services/` - Application services
- `core/theme/` - Visual theming
- `core/widgets/` - Shared widget components

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

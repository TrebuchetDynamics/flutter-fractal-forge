<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# home

## Purpose
Main home screen - the primary entry point after splash/onboarding. Creates a FractalController scoped to the Explore tab and handles deep link navigation.

## Key Files

| File | Description |
|------|-------------|
| `home_screen.dart` | `HomeScreen` - creates FractalController, sets up deep link handling, navigates to catalog/viewer |

## For AI Agents

### Working In This Directory
- FractalController is created HERE (not at app root) and scoped per-tab
- Deep links are handled by parsing `DeepLinkData` and applying to the controller
- Navigation: HomeScreen embeds FractalCatalogScreen, navigates to FractalViewerScreen on selection
- Safe mode flag skips deep link initialization

### Testing Requirements
- `test/home_screen_widget_test.dart`
- `test/home_ar_tab_opens_test.dart`

## Dependencies

### Internal
- `core/modules/module_registry.dart` - Registry for controller initialization
- `core/services/deep_link_service.dart` - Deep link handling
- `catalog/` - Catalog screen
- `viewer/` - Viewer screen
- `renderer/providers/fractal_provider.dart` - FractalController

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/home`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

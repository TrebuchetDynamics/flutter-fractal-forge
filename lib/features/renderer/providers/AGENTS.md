<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# providers

## Purpose
Contains FractalController - the central state manager for fractal rendering. Manages module selection, parameter values, view transformations, presets, and animations.

## Key Files

| File | Description |
|------|-------------|
| `fractal_provider.dart` | `FractalController` extends ChangeNotifier. Manages: module selection, parameter updates with validation/clamping, view state (pan/zoom/rotation), preset apply/randomize, transparent background toggle, morph animations, celebration effects |

## For AI Agents

### Working In This Directory
- FractalController is the MOST IMPORTANT state class in the app
- Created per-tab in HomeScreen (not global)
- Uses ChangeNotifier - call `notifyListeners()` after state changes
- Parameter values stored as `Map<String, Object>` - type promotion gotcha applies
- Includes animation state: morphing between modules, celebration effects
- Test mode detection skips timer-based animations

### Key Methods
- `selectModule(module)` - switch fractal type
- `updateParam(id, value)` - update single parameter with clamping
- `applyPreset(preset)` - restore full state from preset
- `randomize()` - generate random valid parameters
- `resetSession()` - reset to module defaults
- `updateZoom(level)`, `updatePan(offset)` - view manipulation

### Testing Requirements
- `test/fractal_controller_behavior_test.dart` - State behavior
- `test/fractal_controller_clamp_test.dart` - Clamping logic
- `test/fractal_controller_boolean_clamp_test.dart` - Boolean params
- `test/fractal_controller_reset_session_test.dart` - Reset logic
- `test/fractal_controller_widget_test.dart` - Widget integration

## Dependencies

### Internal
- `core/modules/fractal_module.dart` - Module definitions
- `core/modules/module_registry.dart` - Available modules
- `core/models/` - Parameter, Preset, ViewState models

### External
- `vector_math` - Vector math for view state

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/renderer/providers`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

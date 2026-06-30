<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# renderer

## Purpose
Core fractal rendering engine. Contains the GPU-accelerated shader renderer, CPU fallback renderer, gesture handling, and render validation. It consumes FractalController from `core/controllers/`.

## Key Files

| File | Description |
|------|-------------|
| `fractal_renderer.dart` | `FractalRenderer` - main widget: loads shaders, renders via CustomPainter, handles gestures (pan/zoom/rotate), adapts to FractalController state |
| `widgets/fractal_canvas.dart` | `FractalCanvas` - CustomPainter that draws the fractal using FragmentShader |
| `cpu/cpu_fractal_renderer.dart` | `CpuFractalRenderer` - software fallback when GPU shaders unavailable |
| `policy/backend_policy.dart` | `BackendPolicy` - decides GPU vs CPU rendering based on device capabilities |
| `policy/precision_ladder_policy.dart` | `PrecisionLadderPolicy` - manages precision ladder routing, extended GPU preview, and CPU Precision decisions |
| `validation/render_validation.dart` | `RenderValidation` - validates render output correctness |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `widgets/` | Renderer UI, shader loading, painter, and gesture handling |
| `cpu/` | CPU fallback formulas, iterators, isolates, tile workers, and viewport mapping |
| `policy/` | Renderer backend and deep-zoom precision decisions |
| `validation/` | Render output validation and convergence detection |

## For AI Agents

### Working In This Directory
- FractalRenderer requires `FractalController` via Provider ancestor
- Shader loading is async; shows loading/error states while compiling
- Gesture handling differs by dimension: pan+zoom for 2D, rotate+zoom for 3D
- CPU fallback is significantly slower but works without GPU support
- Dynamic resolution scaling: 0.5x during gestures, 1.0x+ when static

### Gesture System
- Single-finger drag: pan (2D) or rotate (3D)
- Pinch-to-zoom: smooth zoom with momentum
- Two-finger rotation: Z-axis rotation (3D)
- Double-tap: reset view

### Testing Requirements
- `test/fractal_renderer_widget_test.dart` - Widget lifecycle
- `test/fractal_renderer_gesture_test.dart` - Gesture input
- `test/fractal_render_audit_test.dart` - Render correctness
- `test/renderer_backend_policy_test.dart` - Backend selection
- `integration_test/render_validation_test.dart` - GPU validation

## Dependencies

### Internal
- `core/modules/fractal_module.dart` - Module definitions
- `core/widgets/error_boundary.dart` - Error handling
- `core/widgets/animation_effects.dart` - Morph transitions

### External
- `vector_math` - 3D transformations

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

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/renderer`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->

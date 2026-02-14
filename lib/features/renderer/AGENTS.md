<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# renderer

## Purpose
Core fractal rendering engine. Contains the GPU-accelerated shader renderer, CPU fallback renderer, gesture handling, render validation, and the FractalController state manager.

## Key Files

| File | Description |
|------|-------------|
| `fractal_renderer.dart` | `FractalRenderer` - main widget: loads shaders, renders via CustomPainter, handles gestures (pan/zoom/rotate), adapts to FractalController state |
| `fractal_canvas.dart` | `FractalCanvas` - CustomPainter that draws the fractal using FragmentShader |
| `cpu_fractal_renderer.dart` | `CpuFractalRenderer` - software fallback when GPU shaders unavailable |
| `backend_policy.dart` | `BackendPolicy` - decides GPU vs CPU rendering based on device capabilities |
| `deep_zoom_precision_policy.dart` | `DeepZoomPrecisionPolicy` - manages precision for extreme zoom levels |
| `render_validation.dart` | `RenderValidation` - validates render output correctness |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `providers/` | FractalController state management (see `providers/AGENTS.md`) |

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
- `core/services/shader_service.dart` - Shader loading
- `core/widgets/error_boundary.dart` - Error handling
- `core/widgets/animation_effects.dart` - Morph transitions

### External
- `vector_math` - 3D transformations

<!-- MANUAL: -->

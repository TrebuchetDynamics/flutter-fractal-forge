<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# modules

## Purpose
Fractal module system - the heart of the rendering architecture. Defines `FractalModule` (a complete fractal type configuration) and `ModuleRegistry` (the master list). Most fractals are built declaratively from the escape-time catalog; custom fractals have dedicated builder files.

## Key Files

| File | Description |
|------|-------------|
| `fractal_module.dart` | `FractalModule` class + `FractalRenderState` + `FractalDimension` enum. Defines: id, shader path, parameters, presets, uniform setter |
| `module_registry.dart` | `ModuleRegistry` - merges escape-time catalog + custom modules + diagnostics into ordered list |
| `common_params.dart` | Shared parameter builders (iterations, bailout, color scheme) used across modules |
| `julia_module.dart` | Julia set module builder (custom seed cx/cy params) |
| `phoenix_module.dart` | Phoenix fractal module builder (custom p/q params) |
| `mandelbulb_module.dart` | Mandelbulb 3D module builder (rotation uniforms, raymarching) |
| `mandelbrot_module.dart` | Mandelbrot module builder (legacy, may overlap with catalog) |
| `burning_ship_module.dart` | Burning Ship module builder |
| `celtic_module.dart` | Celtic Mandelbrot module builder |
| `buffalo_module.dart` | Buffalo fractal module builder |
| `tricorn_module.dart` | Tricorn (Mandelbar) module builder |
| `multibrot3_module.dart` | Multibrot (power 3) module builder |
| `nova_module.dart` | Nova fractal module builder |
| `gpu_gradient_module.dart` | Debug-only GPU gradient test module |
| `gpu_sampler_diag_module.dart` | Debug-only GPU sampler diagnostic module |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `builders/` | Escape-time builder pattern: declarative fractal definitions (see `builders/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- To add a standard escape-time fractal: add `EscapeTimeConfig` to `builders/escape_time_catalog.dart` + register shader in `pubspec.yaml`
- To add a custom fractal: create `build_xxx_module()` function and register in `module_registry.dart`
- `ModuleRegistry` ordering matters for UX (Julia after Mandelbrot, Phoenix after Burning Ship)
- Debug modules (gpu_gradient, gpu_sampler_diag) only appear in debug builds

### Key Types
- `FractalModule` - immutable definition of a fractal type
- `FractalRenderState` - per-frame snapshot (params + view) passed to shader
- `UniformSetter` - callback that maps Dart params to GLSL uniforms
- `ModuleNameBuilder` - callback for localized display names

### Testing Requirements
- Module registry tested in `test/module_registry_widget_test.dart`
- Individual modules tested via renderer and controller tests

## Dependencies

### Internal
- `models/` - FractalParameter, FractalPreset, FractalViewState
- `l10n/` - AppLocalizations for display names

### External
- `vector_math` - 3D math for Mandelbulb

<!-- MANUAL: -->

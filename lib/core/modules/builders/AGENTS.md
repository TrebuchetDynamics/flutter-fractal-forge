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

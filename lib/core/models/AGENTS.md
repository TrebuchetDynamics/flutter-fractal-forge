<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# models

## Purpose
Immutable data classes representing the application's domain model. These define the shape of fractal parameters, presets, view state, and export configuration.

## Key Files

| File | Description |
|------|-------------|
| `fractal_parameter.dart` | `FractalParameter` - defines a single configurable parameter (type, range, step, default) with `FractalParamType` enum |
| `fractal_params.dart` | `FractalParams` - collection of parameter values as a typed map |
| `fractal_preset.dart` | `FractalPreset` - named snapshot of parameters + view state + palette for save/restore |
| `fractal_view_state.dart` | `FractalViewState` - pan offset, zoom level, rotation angles for the viewport |
| `fractal_palette.dart` | `FractalPalette` - color palette definition for fractal coloring |
| `export_options.dart` | `ExportOptions` - image export configuration (resolution, format, transparency) |
| `video_export_options.dart` | `VideoExportOptions` - video/GIF export settings (duration, FPS, resolution) |
| `exploration_stats.dart` | `ExplorationStats` - statistics tracking for exploration sessions |
| `wallpaper_options.dart` | `WallpaperOptions` - wallpaper export settings (placement, scaling) |

## For AI Agents

### Working In This Directory
- Models are immutable (`@immutable` annotation) data containers
- Fields typed as `Object` do NOT get type-promoted in Dart - use local variable first: `final v = value; if (v is num) v.toDouble()`
- Presets are JSON-serializable for persistence via `SharedPreferences`
- `FractalParameter` supports types: float, integer, boolean, enumeration

### Common Patterns
- Constructor-based immutability with `const` constructors where possible
- `copyWith` methods for creating modified copies
- JSON serialization via `toJson()`/`fromJson()` factory constructors

## Dependencies

### External
- `equatable` - Value equality for model comparison
- `vector_math` - Vector types for view state

<!-- MANUAL: -->

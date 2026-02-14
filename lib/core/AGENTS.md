<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# core

## Purpose
Foundation layer of the application. Contains data models, fractal module definitions, application services, theming, and shared widgets. Everything in `core/` is feature-agnostic and can be used by any feature screen.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `models/` | Data classes: FractalParams, FractalPreset, FractalViewState, ExportOptions, etc. (see `models/AGENTS.md`) |
| `modules/` | Fractal module system: FractalModule, ModuleRegistry, escape-time catalog, custom builders (see `modules/AGENTS.md`) |
| `services/` | Application services: export, presets, history, accessibility, shader loading, etc. (see `services/AGENTS.md`) |
| `shaders/` | Shader utility code: uniform schema definitions (see `shaders/AGENTS.md`) |
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

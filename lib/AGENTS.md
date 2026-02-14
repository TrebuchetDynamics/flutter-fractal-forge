<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# lib

## Purpose
Main application source code for Flutter Fractal Forge. Organized into core infrastructure (models, modules, services), feature screens, and shared utilities. Uses Provider for state management with FractalController as the primary state holder.

## Key Files

| File | Description |
|------|-------------|
| `main.dart` | App entry point; initializes services, configures providers, sets up theming and localization. Includes safe/boot mode variants for debugging |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `core/` | Foundation layer: data models, fractal modules, services, theme, widgets (see `core/AGENTS.md`) |
| `features/` | Feature screens and UI components organized by domain (see `features/AGENTS.md`) |
| `shared/` | Cross-cutting utilities shared across features (see `shared/AGENTS.md`) |
| `l10n/` | Generated localization files for EN + ES (see `l10n/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Entry point is `main.dart` which sets up the Provider tree
- FractalController is created per-tab (Explore vs AR) in HomeScreen, NOT at root
- All fractal modules are registered via `ModuleRegistry` at startup
- Services (PresetStore, HistoryStore, etc.) are initialized async before `runApp`

### Architecture Flow
```
main.dart -> FlutterFractalsApp (providers) -> HomeScreen
  -> FractalCatalogScreen (browse fractals)
  -> FractalViewerScreen (render + interact)
  -> ArOverlayScreen (camera + fractal overlay)
```

### Testing Requirements
- Widget tests need mock stores: `PresetStore`, `ArQualityStore`, `HistoryStore`
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

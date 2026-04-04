<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# lib

## Purpose
Main application source code for Flutter Fractal Forge. Organized into core infrastructure, feature surfaces, generated localizations, and shared utilities. Uses Provider for app-scoped services and a `FractalController` created in `HomeScreen` for the explore/viewer flow.

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
- `main.dart` starts with a deferred splash, then initializes services asynchronously
- `FractalController` is created in `HomeScreen`, not at the app root
- `ModuleRegistry` is provided app-wide and currently builds 370 non-debug modules
- Services such as `PresetStore`, `HistoryStore`, `AccessibilityService`, and `RendererSettingsService` are initialized before the full app shell is shown

### Architecture Flow
```
main.dart -> _DeferredStartupApp -> FlutterFractalsApp
  -> onboarding or HomeScreen
  -> FractalCatalogScreen
  -> FractalViewerScreen
```

### Testing Requirements
- Widget tests usually need `PresetStore`, `RendererSettingsService`, and a provided `ModuleRegistry`
- Use `FlutterFractalsApp` constructor parameters to inject test services and locale overrides

### Common Patterns
- Provider-based DI: services provided at root, consumed via `context.read<T>()`
- ChangeNotifier pattern: FractalController notifies listeners on state changes
- Safe mode flags: `SAFE_MODE` and `BOOT_STEP` env vars for incremental debugging

## Dependencies

### External
- `provider` - State management and DI
- `flutter_localizations` - i18n support

<!-- MANUAL: -->

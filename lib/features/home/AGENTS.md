<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# home

## Purpose
Primary post-onboarding entry point. Owns the explore `FractalController`, hosts the catalog screen, and optionally handles deep-link navigation into the viewer when `DeepLinkService` is provided.

## Key Files

| File | Description |
|------|-------------|
| `home_screen.dart` | Creates the explore controller, wires optional deep links, shows the premium app bar, and embeds `FractalCatalogScreen` |

## For AI Agents

### Working In This Directory
- `FractalController` is created here and reused when deep links push the viewer
- Deep-link handling is optional; tests may omit `DeepLinkService` entirely
- `SAFE_MODE` skips deep-link setup and surfaces a diagnostic banner
- The default UI in this directory is the catalog, not a tab shell

### Testing Requirements
- `test/home_screen_widget_test.dart`

## Dependencies

### Internal
- `core/modules/module_registry.dart` - Registry for controller initialization
- `core/services/deep_link_service.dart` - Deep link handling
- `catalog/` - Catalog screen
- `viewer/` - Viewer screen
- `renderer/providers/fractal_provider.dart` - FractalController

<!-- MANUAL: -->

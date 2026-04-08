<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# home

## Purpose
Main home screen - the primary entry point after splash/onboarding. Creates a FractalController scoped to the Explore tab and handles deep link navigation.

## Key Files

| File | Description |
|------|-------------|
| `home_screen.dart` | `HomeScreen` - creates FractalController, sets up deep link handling, navigates to catalog/viewer |

## For AI Agents

### Working In This Directory
- FractalController is created HERE (not at app root) and scoped per-tab
- Deep links are handled by parsing `DeepLinkData` and applying to the controller
- Navigation: HomeScreen embeds FractalCatalogScreen, navigates to FractalViewerScreen on selection
- Safe mode flag skips deep link initialization

### Testing Requirements
- `test/home_screen_widget_test.dart`
- `test/home_ar_tab_opens_test.dart`

## Dependencies

### Internal
- `core/modules/module_registry.dart` - Registry for controller initialization
- `core/services/deep_link_service.dart` - Deep link handling
- `catalog/` - Catalog screen
- `viewer/` - Viewer screen
- `renderer/providers/fractal_provider.dart` - FractalController

<!-- MANUAL: -->

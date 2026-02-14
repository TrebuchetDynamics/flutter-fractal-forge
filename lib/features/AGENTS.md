<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# features

## Purpose
Feature-level screens and UI components, organized by domain. Each subdirectory represents a distinct feature area of the application. Features consume `core/` services and models but should not depend on each other directly.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `ar/` | AR camera overlay screen (see `ar/AGENTS.md`) |
| `auto_explore/` | Autonomous fractal exploration with auto-animation (see `auto_explore/AGENTS.md`) |
| `catalog/` | Fractal catalog browser with search and thumbnails (see `catalog/AGENTS.md`) |
| `controls/` | Parameter control panel (sliders, toggles) (see `controls/AGENTS.md`) |
| `debug/` | Debug overlays for performance, shader, and rendering diagnostics (see `debug/AGENTS.md`) |
| `export/` | Image/video export dialogs and options (see `export/AGENTS.md`) |
| `history/` | Exploration history tracking and browsing (see `history/AGENTS.md`) |
| `home/` | Main home screen with tab navigation (see `home/AGENTS.md`) |
| `minimap/` | Fractal minimap overview widget (see `minimap/AGENTS.md`) |
| `onboarding/` | First-launch onboarding flow (see `onboarding/AGENTS.md`) |
| `presets/` | Preset selection and management panel (see `presets/AGENTS.md`) |
| `renderer/` | Core fractal rendering engine with GPU/CPU backends (see `renderer/AGENTS.md`) |
| `settings/` | Accessibility settings screen (see `settings/AGENTS.md`) |
| `viewer/` | Full fractal viewer screen with controls integration (see `viewer/AGENTS.md`) |
| `wallpaper/` | Wallpaper export options (see `wallpaper/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each feature is self-contained in its own directory
- Features access shared state via Provider (FractalController, services)
- Navigation flow: HomeScreen -> CatalogScreen -> ViewerScreen
- FractalController is scoped per-tab (created in HomeScreen), not global

### Architecture Rules
- Features depend on `core/` but NOT on each other
- Cross-feature communication goes through Provider/services
- Each feature directory typically has 1-3 Dart files
- UI-heavy features may have widget extraction files

## Dependencies

### Internal
- `core/models/` - Data classes
- `core/modules/` - Fractal module definitions
- `core/services/` - Application services
- `core/theme/` - Visual theming
- `core/widgets/` - Shared widget components

<!-- MANUAL: -->

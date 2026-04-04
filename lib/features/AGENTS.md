<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# features

## Purpose
Feature-level screens and UI components, organized by domain. Most features consume `core/` services and models; the viewer layer also composes several feature widgets such as controls, presets, export, minimap, and history.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `auto_explore/` | Autonomous fractal exploration with auto-animation (see `auto_explore/AGENTS.md`) |
| `catalog/` | Fractal catalog browser with search and thumbnails (see `catalog/AGENTS.md`) |
| `controls/` | Parameter control panel (sliders, toggles) (see `controls/AGENTS.md`) |
| `debug/` | Debug overlays for performance, shader, and rendering diagnostics (see `debug/AGENTS.md`) |
| `export/` | Image export UI plus batch/video scaffolding used for ongoing export work (see `export/AGENTS.md`) |
| `history/` | Exploration history tracking and browsing (see `history/AGENTS.md`) |
| `home/` | Main explore entry point; owns the catalog-scoped controller and optional deep-link handling (see `home/AGENTS.md`) |
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
- Navigation flow: HomeScreen -> FractalCatalogScreen -> FractalViewerScreen
- FractalController is scoped to the explore flow in `home/`, not global
- Catalog and viewer now include additional state helpers for view mode persistence, screen data building, backend policy, and debug/report surfaces

### Architecture Rules
- Most feature state changes go through Provider/services
- Some features are intentionally composed into the viewer surface instead of being isolated routes
- UI-heavy features often include extracted widgets, helper state objects, or mixins

## Dependencies

### Internal
- `core/models/` - Data classes
- `core/modules/` - Fractal module definitions
- `core/services/` - Application services
- `core/theme/` - Visual theming
- `core/widgets/` - Shared widget components

<!-- MANUAL: -->

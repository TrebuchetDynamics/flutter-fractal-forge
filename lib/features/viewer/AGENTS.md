<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# viewer

## Purpose
Full fractal viewer screen. Integrates the renderer, backend policy, controls, presets, export, history, minimap, auto-explore, and debug/report helpers into the main interactive experience.

## Key Files

| File | Description |
|------|-------------|
| `fractal_viewer_screen.dart` | Main viewer route and mixin host for GPU health, export actions, history recording, HUD, and dialogs |

## For AI Agents

### Working In This Directory
- Requires FractalController provided via Provider ancestor
- Known issue: `ProviderNotFoundException` if provider not wrapped around viewer route
- Assembles multiple feature widgets: renderer, controls, presets, export, history, minimap, debug helpers, and auto-explore
- Backend decisions depend on renderer settings, GPU health checks, and deep-zoom precision policy
- Export is image-focused in the current release; older docs mentioning video or AR overlays are historical

### Testing Requirements
- `test/fractal_viewer_screen_widget_test.dart`

## Dependencies

### Internal
- `renderer/` - Fractal rendering
- `controls/` - Parameter controls
- `presets/` - Preset panel
- `export/` - Export dialogs
- `minimap/` - Overview widget
- `auto_explore/` - Auto-exploration
- `debug/` - Debug overlays

<!-- MANUAL: -->

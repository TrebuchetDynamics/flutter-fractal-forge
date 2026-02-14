<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# viewer

## Purpose
Full fractal viewer screen - the main interactive experience. Integrates the renderer, controls panel, presets, export options, minimap, and auto-explore into a cohesive viewing experience.

## Key Files

| File | Description |
|------|-------------|
| `fractal_viewer_screen.dart` | `FractalViewerScreen` - full-screen fractal viewer with bottom sheet controls, toolbar buttons (presets, export, AR), and overlay widgets (minimap, debug, auto-explore) |

## For AI Agents

### Working In This Directory
- Requires FractalController provided via Provider ancestor
- Known issue: `ProviderNotFoundException` if provider not wrapped around viewer route
- Assembles multiple feature widgets: renderer, controls, presets, export, minimap
- Toolbar provides access to presets sheet, export sheet, AR mode

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

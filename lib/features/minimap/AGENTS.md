<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# minimap

## Purpose
Minimap widget showing a zoomed-out overview of the current fractal with a viewport indicator. Helps users orient themselves when deeply zoomed in.

## Key Files

| File | Description |
|------|-------------|
| `fractal_minimap.dart` | `FractalMinimap` - small corner widget showing full fractal with current viewport rectangle |

## For AI Agents

### Working In This Directory
- Renders a low-resolution version of the current fractal
- Viewport rectangle shows the current zoom/pan region
- Tapping the minimap can jump to that region

## Dependencies

### Internal
- `renderer/providers/fractal_provider.dart` - Current view state

<!-- MANUAL: -->

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# auto_explore

## Purpose
Autonomous fractal exploration feature. Automatically pans, zooms, and adjusts parameters to discover visually interesting regions of fractal space. Provides play/pause controls and speed adjustment.

## Key Files

| File | Description |
|------|-------------|
| `auto_explore.dart` | `AutoExplore` widget - main auto-explore UI integration |
| `auto_explore_controls.dart` | Play/pause, speed, and mode controls for auto-exploration |
| `auto_explore_service.dart` | `AutoExploreService` - algorithm that drives autonomous exploration (zoom targets, parameter sweeps) |

## For AI Agents

### Working In This Directory
- Auto-explore only enabled for supported fractals (not all 200+ support it)
- The service manipulates FractalController's view state and parameters
- Speed and exploration mode are user-configurable

## Dependencies

### Internal
- `renderer/providers/fractal_provider.dart` - FractalController manipulation
- `core/models/fractal_view_state.dart` - View state updates

<!-- MANUAL: -->

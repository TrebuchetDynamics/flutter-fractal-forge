<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# providers

## Purpose
Contains FractalController - the central state manager for fractal rendering. Manages module selection, parameter values, view transformations, presets, and animations.

## Key Files

| File | Description |
|------|-------------|
| `fractal_provider.dart` | `FractalController` extends ChangeNotifier. Manages: module selection, parameter updates with validation/clamping, view state (pan/zoom/rotation), preset apply/randomize, transparent background toggle, morph animations, celebration effects |

## For AI Agents

### Working In This Directory
- FractalController is the MOST IMPORTANT state class in the app
- Created per-tab in HomeScreen (not global)
- Uses ChangeNotifier - call `notifyListeners()` after state changes
- Parameter values stored as `Map<String, Object>` - type promotion gotcha applies
- Includes animation state: morphing between modules, celebration effects
- Test mode detection skips timer-based animations

### Key Methods
- `selectModule(module)` - switch fractal type
- `updateParam(id, value)` - update single parameter with clamping
- `applyPreset(preset)` - restore full state from preset
- `randomize()` - generate random valid parameters
- `resetSession()` - reset to module defaults
- `updateZoom(level)`, `updatePan(offset)` - view manipulation

### Testing Requirements
- `test/fractal_controller_behavior_test.dart` - State behavior
- `test/fractal_controller_clamp_test.dart` - Clamping logic
- `test/fractal_controller_boolean_clamp_test.dart` - Boolean params
- `test/fractal_controller_reset_session_test.dart` - Reset logic
- `test/fractal_controller_widget_test.dart` - Widget integration

## Dependencies

### Internal
- `core/modules/fractal_module.dart` - Module definitions
- `core/modules/module_registry.dart` - Available modules
- `core/models/` - Parameter, Preset, ViewState models

### External
- `vector_math` - Vector math for view state

<!-- MANUAL: -->

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# controls

## Purpose
Parameter control sheet for adjusting fractal parameters in real time. Generates compact sliders, toggles, and selectors dynamically from the active module schema and includes quick actions for reset/randomize.

## Key Files

| File | Description |
|------|-------------|
| `fractal_controls.dart` | Bottom-sheet UI for parameter controls and quick actions |
| `fractal_control_value_resolver.dart` | Resolves raw controller values into typed values used by the control widgets |

## For AI Agents

### Working In This Directory
- Controls are generated dynamically from `FractalModule.parameters`
- Each parameter type maps to a compact widget variant tuned for the viewer bottom sheet
- Parameter values stored as `Object` in FractalController - use local variable for type promotion
- Dart gotcha: `Object` fields do NOT type-promote; assign to `final v = value;` first

### Testing Requirements
- `test/fractal_controls_comprehensive_test.dart`
- `test/fractal_control_value_resolver_test.dart`

## Dependencies

### Internal
- `core/models/fractal_parameter.dart` - Parameter schema definitions
- `renderer/providers/fractal_provider.dart` - FractalController for state updates

<!-- MANUAL: -->

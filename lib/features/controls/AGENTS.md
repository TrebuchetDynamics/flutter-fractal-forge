<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# controls

## Purpose
Parameter control panel for adjusting fractal parameters in real-time. Generates sliders, toggles, and dropdowns dynamically from the active module's parameter schema.

## Key Files

| File | Description |
|------|-------------|
| `fractal_controls.dart` | `FractalControls` - schema-driven control panel that renders sliders/toggles based on `FractalParameter` definitions. Handles float, int, boolean, and enum parameter types |

## For AI Agents

### Working In This Directory
- Controls are generated dynamically from `FractalModule.parameters`
- Each parameter type maps to a specific widget (Slider, Switch, DropdownButton)
- Parameter values stored as `Object` in FractalController - use local variable for type promotion
- Dart gotcha: `Object` fields do NOT type-promote; assign to `final v = value;` first

### Testing Requirements
- `test/fractal_controls_comprehensive_test.dart`
- `test/fractal_controls_sheet_widget_test.dart`

## Dependencies

### Internal
- `core/models/fractal_parameter.dart` - Parameter schema definitions
- `renderer/providers/fractal_provider.dart` - FractalController for state updates

<!-- MANUAL: -->

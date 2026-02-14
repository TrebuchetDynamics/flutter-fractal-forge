<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# presets

## Purpose
Preset selection and management panel. Displays built-in and user-created presets for the current fractal module, with save/delete/rename functionality.

## Key Files

| File | Description |
|------|-------------|
| `preset_sheet.dart` | `PresetSheet` - bottom sheet showing preset grid with thumbnails, save button, and management options |

## For AI Agents

### Working In This Directory
- Built-in presets come from `FractalModule.builtInPresets`
- User presets stored via `PresetStore` (SharedPreferences)
- Applying a preset updates FractalController with the preset's params + view state
- Randomize button generates random valid parameter values

### Testing Requirements
- `test/preset_sheet_widget_test.dart`
- `test/preset_sheet_comprehensive_test.dart`

## Dependencies

### Internal
- `core/services/preset_store.dart` - User preset persistence
- `core/models/fractal_preset.dart` - Preset data model
- `renderer/providers/fractal_provider.dart` - Apply preset to controller

<!-- MANUAL: -->

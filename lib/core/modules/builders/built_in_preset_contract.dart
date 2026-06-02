import 'package:flutter_fractals/core/models/fractal_preset.dart';

/// Stable provenance marker for generated built-in presets.
///
/// Builder-owned presets are part of the app catalog, not user-created data, so
/// their metadata must be replayable across registry rebuilds and test runs.
final builtInPresetCreatedAt = DateTime.utc(2025, 1, 1);

/// Returns the builder-facing built-in preset list with replayable metadata.
///
/// Catalog entries often provide curated [extraPresets] for params/view only.
/// Normalize them here so callers cannot accidentally surface mutable-looking or
/// non-replayable presets in [FractalModule.builtInPresets].
List<FractalPreset> buildBuiltInPresetList({
  required FractalPreset defaultPreset,
  required List<FractalPreset> extraPresets,
}) {
  return [
    defaultPreset.copyWith(
        id: '${defaultPreset.moduleId}-classic', name: 'Classic'),
    ...extraPresets.map(_asReplayableBuiltInPreset),
  ];
}

FractalPreset _asReplayableBuiltInPreset(FractalPreset preset) {
  return preset.copyWith(
    createdAt: builtInPresetCreatedAt,
    isBuiltIn: true,
  );
}

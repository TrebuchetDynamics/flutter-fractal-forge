import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';

/// Stable provenance marker for generated built-in presets.
///
/// Builder-owned presets are part of the app catalog, not user-created data, so
/// their metadata must be replayable across registry rebuilds and test runs.
final builtInPresetCreatedAt = DateTime.utc(2025, 1, 1);

/// Constructs a curated built-in catalog preset with replayable provenance.
///
/// Catalog entries only vary by [id], [moduleId], [name], [params], and [view];
/// the provenance fields ([createdAt], [isBuiltIn]) are fixed by contract. This
/// factory bakes them in so catalog data cannot accidentally reintroduce
/// non-deterministic timestamps (e.g. `DateTime.now()`) or a wrong built-in flag.
FractalPreset catalogPreset({
  required String id,
  required String moduleId,
  required String name,
  required Map<String, Object> params,
  required FractalViewState view,
  String? thumbnailPath,
}) {
  return FractalPreset(
    id: id,
    moduleId: moduleId,
    name: name,
    params: params,
    view: view,
    createdAt: builtInPresetCreatedAt,
    isBuiltIn: true,
    thumbnailPath: thumbnailPath,
  );
}

/// Returns the builder-facing built-in preset list with replayable metadata.
///
/// Catalog entries often provide curated [extraPresets] for params/view only.
/// Normalize them here so callers cannot accidentally surface mutable-looking,
/// non-replayable, or stale-module presets in [FractalModule.builtInPresets].
List<FractalPreset> buildBuiltInPresetList({
  required String moduleId,
  required FractalPreset defaultPreset,
  required List<FractalPreset> extraPresets,
}) {
  assert(moduleId.isNotEmpty, 'Built-in presets require a module id.');
  assert(
    defaultPreset.moduleId == moduleId,
    'Default built-in preset moduleId must match its module.',
  );

  final usedIds = <String>{};
  return [
    _asReplayableBuiltInPreset(
      defaultPreset.copyWith(id: '$moduleId-classic', name: 'Classic'),
      moduleId,
      usedIds,
    ),
    ...extraPresets.map((preset) => _asReplayableBuiltInPreset(
          preset,
          moduleId,
          usedIds,
        )),
  ];
}

FractalPreset _asReplayableBuiltInPreset(
  FractalPreset preset,
  String moduleId,
  Set<String> usedIds,
) {
  return preset.copyWith(
    id: _uniquePresetId(preset.id, usedIds),
    moduleId: moduleId,
    createdAt: builtInPresetCreatedAt,
    isBuiltIn: true,
  );
}

String _uniquePresetId(String id, Set<String> usedIds) {
  if (usedIds.add(id)) return id;

  var suffix = 2;
  while (true) {
    final candidate = '$id-$suffix';
    if (usedIds.add(candidate)) return candidate;
    suffix++;
  }
}

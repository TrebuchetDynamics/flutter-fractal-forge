import 'package:flutter_fractals/core/models/fractal_preset.dart';

/// SharedPreferences slot for one module's user presets.
///
/// A slot key is module-specific, so decoded entries must also prove they belong
/// to the same module. This keeps stale or corrupted payloads from leaking a
/// preset into another module's picker and from being preserved on the next save.
final class PresetStorageSlot {
  final String moduleId;

  const PresetStorageSlot(this.moduleId);

  String get key => 'user_presets_$moduleId';

  List<FractalPreset> decode(String? payload) {
    return _matchingModule(FractalPreset.listFromPrefs(payload))
        .toList(growable: false);
  }

  String encode(Iterable<FractalPreset> presets) {
    final input = presets.toList(growable: false);
    final matching = _matchingModule(input).toList(growable: false);

    assert(
      matching.length == input.length,
      'PresetStorageSlot can only encode presets for "$moduleId"',
    );

    return FractalPreset.listToPrefs(matching);
  }

  Iterable<FractalPreset> _matchingModule(Iterable<FractalPreset> presets) {
    return presets.where((preset) => preset.moduleId == moduleId);
  }
}

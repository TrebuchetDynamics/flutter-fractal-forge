import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';

class PresetStore {
  final SharedPreferences _prefs;

  PresetStore._(this._prefs);

  static Future<PresetStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PresetStore._(prefs);
  }

  Future<List<FractalPreset>> loadUserPresets(String moduleId) async {
    final payload = _prefs.getString(_key(moduleId));
    return FractalPreset.listFromPrefs(payload);
  }

  Future<void> saveUserPreset(FractalPreset preset) async {
    final presets = await loadUserPresets(preset.moduleId);
    // Check for duplicate ID and replace if exists
    final existingIndex = presets.indexWhere((p) => p.id == preset.id);
    final List<FractalPreset> updated;
    if (existingIndex >= 0) {
      // Replace existing preset with same ID
      updated = [...presets];
      updated[existingIndex] = preset;
    } else {
      // Add new preset
      updated = [...presets, preset];
    }
    await _prefs.setString(_key(preset.moduleId), FractalPreset.listToPrefs(updated));
  }

  Future<void> deleteUserPreset(String moduleId, String presetId) async {
    final presets = await loadUserPresets(moduleId);
    final updated = presets.where((preset) => preset.id != presetId).toList();
    await _prefs.setString(_key(moduleId), FractalPreset.listToPrefs(updated));
  }

  Future<void> updatePreset(String moduleId, String presetId, {required String name}) async {
    final presets = await loadUserPresets(moduleId);
    final index = presets.indexWhere((p) => p.id == presetId);
    if (index < 0) return;
    final updated = [...presets];
    updated[index] = presets[index].copyWith(name: name);
    await _prefs.setString(_key(moduleId), FractalPreset.listToPrefs(updated));
  }

  String _key(String moduleId) => 'user_presets_$moduleId';
}

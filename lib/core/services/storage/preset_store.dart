import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/services/storage/preset_storage_slot.dart';

class PresetStore {
  final SharedPreferences _prefs;

  PresetStore._(this._prefs);

  static Future<PresetStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PresetStore._(prefs);
  }

  Future<List<FractalPreset>> loadUserPresets(String moduleId) async {
    return _loadSlot(PresetStorageSlot(moduleId));
  }

  Future<void> saveUserPreset(FractalPreset preset) async {
    final slot = PresetStorageSlot(preset.moduleId);
    final presets = _loadSlot(slot);
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
    await _saveSlot(slot, updated);
  }

  Future<void> deleteUserPreset(String moduleId, String presetId) async {
    final slot = PresetStorageSlot(moduleId);
    final presets = _loadSlot(slot);
    final updated = presets.where((preset) => preset.id != presetId).toList();
    await _saveSlot(slot, updated);
  }

  Future<void> updatePreset(
    String moduleId,
    String presetId, {
    required String name,
  }) async {
    final slot = PresetStorageSlot(moduleId);
    final presets = _loadSlot(slot);
    final index = presets.indexWhere((p) => p.id == presetId);
    if (index < 0) return;
    final updated = [...presets];
    updated[index] = presets[index].copyWith(name: name);
    await _saveSlot(slot, updated);
  }

  List<FractalPreset> _loadSlot(PresetStorageSlot slot) {
    return slot.decode(_prefs.getString(slot.key));
  }

  Future<void> _saveSlot(
    PresetStorageSlot slot,
    List<FractalPreset> presets,
  ) async {
    await _prefs.setString(slot.key, slot.encode(presets));
  }
}

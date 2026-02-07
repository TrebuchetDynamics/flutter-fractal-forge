import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/models/ar_quality_preset.dart';

class ArQualityStore {
  static const _key = 'ar_quality_preset';
  final SharedPreferences _prefs;

  ArQualityStore._(this._prefs);

  static Future<ArQualityStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ArQualityStore._(prefs);
  }

  ArQualityPreset getPreset() {
    final raw = _prefs.getString(_key);
    switch (raw) {
      case 'low':
        return ArQualityPreset.low;
      case 'high':
        return ArQualityPreset.high;
      case 'medium':
      default:
        return ArQualityPreset.medium;
    }
  }

  Future<void> setPreset(ArQualityPreset preset) async {
    await _prefs.setString(_key, preset.name);
  }
}

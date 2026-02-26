import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';

class PaletteStore {
  static const _key = 'user_palettes_v1';

  final SharedPreferences _prefs;

  PaletteStore._(this._prefs);

  static Future<PaletteStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PaletteStore._(prefs);
  }

  List<FractalPalette> loadPalettes() {
    final list = _prefs.getStringList(_key);
    if (list != null) {
      return list
          .map((s) => FractalPalette.fromJsonString(s))
          .where((p) => p.id.isNotEmpty)
          .toList();
    }

    final payload = _prefs.getString(_key);
    if (payload == null || payload.trim().isEmpty) return const [];

    try {
      final decodedArr = (jsonDecode(payload) as List).cast<Map>();
      return decodedArr
          .map((m) => FractalPalette.fromJson(m.cast<String, Object?>()))
          .where((p) => p.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('[FF] silent catch: $e');
      return const [];
    }
  }

  Future<void> savePalettes(List<FractalPalette> palettes) async {
    final list = palettes.map((p) => p.toJsonString(pretty: false)).toList();
    await _prefs.setStringList(_key, list);
  }
}

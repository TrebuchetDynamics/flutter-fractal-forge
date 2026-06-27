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
    return _decodePalettePayload(_prefs.get(_key));
  }

  List<FractalPalette> _decodePalettePayload(Object? payload) {
    if (payload == null) return const [];
    if (payload is String) return _decodeLegacyPaletteArray(payload);
    if (payload is List) return _decodePaletteListPayload(payload);
    return const [];
  }

  List<FractalPalette> _decodePaletteListPayload(List<Object?> payload) {
    final encodedPalettes = <String>[];
    for (final entry in payload) {
      if (entry is! String) return const [];
      encodedPalettes.add(entry);
    }
    return _decodePaletteStringList(encodedPalettes);
  }

  List<FractalPalette> _decodePaletteStringList(List<String> encodedPalettes) {
    final palettes = <FractalPalette>[];
    for (final encoded in encodedPalettes) {
      final palette = _tryDecodePaletteString(encoded);
      if (palette != null && palette.id.isNotEmpty) palettes.add(palette);
    }
    return palettes;
  }

  FractalPalette? _tryDecodePaletteString(String encoded) {
    try {
      return FractalPalette.fromJsonString(encoded);
    } catch (e) {
      if (kDebugMode) debugPrint('[FF] skipping palette entry: $e');
      return null;
    }
  }

  List<FractalPalette> _decodeLegacyPaletteArray(String? payload) {
    if (payload == null || payload.trim().isEmpty) return const [];

    try {
      final decodedArr = jsonDecode(payload);
      if (decodedArr is! List) return const [];
      final palettes = <FractalPalette>[];
      for (final entry in decodedArr) {
        try {
          if (entry is! Map) continue;
          final palette = FractalPalette.fromJson(
            entry.cast<String, Object?>(),
          );
          if (palette.id.isNotEmpty) palettes.add(palette);
        } catch (e) {
          if (kDebugMode) debugPrint('[FF] skipping legacy palette entry: $e');
        }
      }
      return palettes;
    } catch (e) {
      if (kDebugMode) debugPrint('[FF] silent catch: $e');
      return const [];
    }
  }

  Future<void> savePalettes(List<FractalPalette> palettes) async {
    final list = palettes.map((p) => p.toJsonString(pretty: false)).toList();
    await _prefs.setStringList(_key, list);
  }
}

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/storage/palette_store.dart';

const List<FractalColorStop> _fallbackPaletteStops =
    fallbackFractalPaletteStops;

/// Normalizes palette stops before persistence or shader texture/uniform upload.
///
/// Kept as the service-level compatibility helper while the replayable contract
/// lives in the palette model for gradient and shader consumers alike.
List<FractalColorStop> normalizePaletteStops(List<FractalColorStop> stops) {
  return normalizeFractalPaletteStops(
    stops,
    maxStops: PaletteService.maxStops,
  );
}

String _uniquePaletteId(String requestedId, Set<String> reservedIds) {
  var candidate = requestedId;
  if (!reservedIds.contains(candidate)) return candidate;
  var i = 2;
  while (reservedIds.contains('$candidate-$i')) {
    i++;
  }
  return '$candidate-$i';
}

/// Manages built-in and user-created color palettes.
///
/// Palettes are persisted locally using [PaletteStore].
class PaletteService extends ChangeNotifier {
  static PaletteService? _instance;
  static PaletteService get instance {
    final v = _instance;
    if (v == null) {
      throw StateError('PaletteService not initialized');
    }
    return v;
  }

  static const int maxStops = maxFractalPaletteStops;
  static const int _texWidth = 256;

  final PaletteStore _store;

  /// Cache of palette textures keyed by palette id.
  final Map<String, ui.Image> _paletteTexCache = {};

  late final List<FractalPalette> _builtIn;
  List<FractalPalette> _user = const [];

  PaletteService._(this._store) {
    _builtIn = _createBuiltIns();
  }

  static Future<PaletteService> create({PaletteStore? store}) async {
    final s = store ?? await PaletteStore.create();
    final service = PaletteService._(s);
    await service._load();
    _instance = service;
    return service;
  }

  List<FractalPalette> get builtInPalettes => List.unmodifiable(_builtIn);
  List<FractalPalette> get userPalettes => List.unmodifiable(_user);
  List<FractalPalette> get allPalettes =>
      List.unmodifiable([..._builtIn, ..._user]);

  int get builtInCount => _builtIn.length;

  FractalPalette paletteAtIndex(int index) {
    final all = allPalettes;
    if (all.isEmpty) {
      return FractalPalette(
        id: 'fallback',
        name: 'Fallback',
        stops: _fallbackPaletteStops,
      );
    }
    if (index < 0 || index >= all.length) return all.first;
    return all[index];
  }

  bool isBuiltInIndex(int index) => index >= 0 && index < builtInCount;

  Future<void> addPalette(FractalPalette palette) async {
    await _commitUserPalettes([
      ..._user,
      _prepareNewUserPalette(palette),
    ]);
  }

  Future<void> updatePalette(FractalPalette palette) async {
    await _commitUserPalettes(
      _user
          .map((p) => p.id == palette.id
              ? palette.copyWith(
                  isBuiltIn: false,
                  stops: normalizePaletteStops(palette.stops),
                )
              : p)
          .toList(),
    );
  }

  Future<void> deletePalette(String id) async {
    await _commitUserPalettes(_user.where((p) => p.id != id).toList());
  }

  /// Imports a palette from JSON. If id is missing/duplicate, a new id is generated.
  Future<FractalPalette> importPaletteJson(String input) async {
    final palette = _prepareNewUserPalette(
      FractalPalette.fromJsonString(input),
    );
    await _commitUserPalettes([..._user, palette]);
    return palette;
  }

  String exportPaletteJson(FractalPalette palette, {bool pretty = true}) {
    return palette.copyWith(isBuiltIn: false).toJsonString(pretty: pretty);
  }

  FractalPalette createEmptyPalette({String? name}) {
    final id = _allocateUserPaletteId('');
    return FractalPalette(
      id: id,
      name: name ?? 'Custom Palette',
      stops: _fallbackPaletteStops,
      isBuiltIn: false,
    );
  }

  /// Returns a 256×1 [ui.Image] representing the palette gradient.
  ///
  /// The image is cached per palette id and reused across frames.
  /// Use with `shader.setImageSampler(0, image)` to pass palette as texture.
  ui.Image paletteTexture(FractalPalette palette) {
    final cached = _paletteTexCache[palette.id];
    if (cached != null) return cached;

    final stops = normalizePaletteStops(palette.stops);

    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec, Rect.fromLTWH(0, 0, _texWidth.toDouble(), 1));
    final gradColors = stops.map((s) => Color(s.colorArgb)).toList();
    final gradStops = stops.map((s) => s.position.clamp(0.0, 1.0)).toList();
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(_texWidth.toDouble(), 0),
        gradColors,
        gradStops,
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, _texWidth.toDouble(), 1), paint);
    final pic = rec.endRecording();
    final img = pic.toImageSync(_texWidth, 1);
    _paletteTexCache[palette.id] = img;
    return img;
  }

  /// Clears cached palette textures (call if palettes change).
  void invalidatePaletteTextures() {
    for (final img in _paletteTexCache.values) {
      img.dispose();
    }
    _paletteTexCache.clear();
  }

  /// Writes custom palette uniforms expected by the shaders.
  ///
  /// Layout:
  /// - [baseIndex + 0] = stopCount
  /// - then 8 vec4 stops, each: r, g, b, position
  void setCustomPaletteUniforms(
    ui.FragmentShader shader,
    int baseIndex,
    FractalPalette palette,
  ) {
    // NOTE: This API is legacy. Prefer setting palette uniforms via a
    // UniformSchema/UniformWriter to avoid hard-coded float indices.

    final stops = normalizePaletteStops(palette.stops);
    final count = stops.length.clamp(0, maxStops);
    shader.setFloat(baseIndex, count.toDouble());

    // Fill remaining with last stop to avoid NaNs in shader.
    final padded = [...stops];
    while (padded.length < maxStops) {
      padded.add(padded.last);
    }

    for (var i = 0; i < maxStops; i++) {
      final s = padded[i];
      final c = Color(s.colorArgb);
      final idx = baseIndex + 1 + i * 4;
      // Flutter 3.19 Color channels are 0-255 ints; normalize to 0.0-1.0.
      shader.setFloat(idx + 0, (c.r * 255.0).round().clamp(0, 255) / 255.0);
      shader.setFloat(idx + 1, (c.g * 255.0).round().clamp(0, 255) / 255.0);
      shader.setFloat(idx + 2, (c.b * 255.0).round().clamp(0, 255) / 255.0);
      shader.setFloat(idx + 3, s.position.clamp(0.0, 1.0));
    }
  }

  Future<void> _commitUserPalettes(List<FractalPalette> palettes) async {
    _user = palettes;
    invalidatePaletteTextures();
    await _store.savePalettes(_user);
    notifyListeners();
  }

  Future<void> _load() async {
    _user = _store
        .loadPalettes()
        .map((p) => p.copyWith(
              stops: normalizePaletteStops(p.stops),
              isBuiltIn: false,
            ))
        .toList();
    invalidatePaletteTextures();
  }

  FractalPalette _prepareNewUserPalette(FractalPalette palette) {
    return palette.copyWith(
      id: _allocateUserPaletteId(palette.id),
      isBuiltIn: false,
      stops: normalizePaletteStops(palette.stops),
    );
  }

  String _allocateUserPaletteId(String requestedId) {
    return _uniquePaletteId(
      requestedId.isEmpty ? _randomId() : requestedId,
      {..._builtIn.map((p) => p.id), ..._user.map((p) => p.id)},
    );
  }

  String _randomId() {
    final r = Random();
    final v = r.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    return 'pal_$v';
  }

  static List<FractalPalette> _createBuiltIns() {
    return [
      FractalPalette(
        id: 'builtin_fire',
        name: 'Fire',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF0D0D12),
          FractalColorStop(position: 0.35, colorArgb: 0xFF6B1D1D),
          FractalColorStop(position: 0.7, colorArgb: 0xFFF05A28),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFE066),
        ],
      ),
      FractalPalette(
        id: 'builtin_ocean',
        name: 'Ocean',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF06141C),
          FractalColorStop(position: 0.4, colorArgb: 0xFF0B7285),
          FractalColorStop(position: 0.8, colorArgb: 0xFF22B8CF),
          FractalColorStop(position: 1.0, colorArgb: 0xFFA5D8FF),
        ],
      ),
      FractalPalette(
        id: 'builtin_psychedelic',
        name: 'Psychedelic',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF3B0A45),
          FractalColorStop(position: 0.33, colorArgb: 0xFF7C3AED),
          FractalColorStop(position: 0.66, colorArgb: 0xFF06B6D4),
          FractalColorStop(position: 1.0, colorArgb: 0xFFF59E0B),
        ],
      ),
      FractalPalette(
        id: 'builtin_grayscale',
        name: 'Grayscale',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
        ],
      ),
    ];
  }
}

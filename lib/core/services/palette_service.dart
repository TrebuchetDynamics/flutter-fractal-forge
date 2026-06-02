import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/palette_store.dart';

const List<FractalColorStop> _fallbackPaletteStops = [
  FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
  FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
];

/// Normalizes palette stops before persistence or shader uniform upload.
///
/// The shader uniform path can carry at most [PaletteService.maxStops] stops,
/// but the bounded list must still span the whole gradient. When an imported
/// palette has too many stops, retain both endpoint colors and drop middle
/// candidates instead of truncating away the final 1.0 stop.
List<FractalColorStop> normalizePaletteStops(List<FractalColorStop> stops) {
  if (stops.isEmpty) return _fallbackPaletteStops;

  final sorted = [...stops]..sort((a, b) => a.position.compareTo(b.position));
  final clamped = sorted
      .map((stop) => stop.copyWith(position: stop.position.clamp(0.0, 1.0)))
      .toList();

  final bounded = clamped.length > PaletteService.maxStops
      ? [
          ...clamped.take(PaletteService.maxStops - 1),
          clamped.last,
        ]
      : clamped;

  // Endpoint invariants are part of the gradient contract, including after the
  // max-stop cap is applied.
  bounded[0] = bounded.first.copyWith(position: 0.0);
  bounded[bounded.length - 1] = bounded.last.copyWith(position: 1.0);

  assert(bounded.length <= PaletteService.maxStops);
  assert(bounded.first.position == 0.0);
  assert(bounded.last.position == 1.0);
  return bounded;
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

  static const int maxStops = 8;
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
      return const FractalPalette(
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
      palette.copyWith(
        isBuiltIn: false,
        stops: normalizePaletteStops(palette.stops),
      ),
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
    final parsed = FractalPalette.fromJsonString(input);
    final id = _ensureUniqueId(parsed.id.isEmpty ? _randomId() : parsed.id);
    final palette = parsed.copyWith(
      id: id,
      stops: normalizePaletteStops(parsed.stops),
      isBuiltIn: false,
    );
    await addPalette(palette);
    return palette;
  }

  String exportPaletteJson(FractalPalette palette, {bool pretty = true}) {
    return palette.copyWith(isBuiltIn: false).toJsonString(pretty: pretty);
  }

  FractalPalette createEmptyPalette({String? name}) {
    final id = _ensureUniqueId(_randomId());
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

    final stops = [...palette.stops]
      ..sort((a, b) => a.position.compareTo(b.position));
    if (stops.isEmpty) {
      stops.addAll(_fallbackPaletteStops);
    }

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

  String _ensureUniqueId(String id) {
    var candidate = id;
    final ids = {..._builtIn.map((p) => p.id), ..._user.map((p) => p.id)};
    if (!ids.contains(candidate)) return candidate;
    var i = 2;
    while (ids.contains('$candidate-$i')) {
      i++;
    }
    return '$candidate-$i';
  }

  String _randomId() {
    final r = Random();
    final v = r.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    return 'pal_$v';
  }

  static List<FractalPalette> _createBuiltIns() {
    return const [
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

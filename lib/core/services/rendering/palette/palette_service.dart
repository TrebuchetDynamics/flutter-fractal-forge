import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_texture_cache.dart';
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

  final PaletteStore _store;
  final PaletteTextureCache _paletteTextures = PaletteTextureCache();

  late final List<FractalPalette> _builtIn;
  List<FractalPalette> _user = const [];
  bool _disposed = false;

  void _notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }

  PaletteService._(this._store) {
    _builtIn = _createBuiltIns();
  }

  static Future<PaletteService> create({PaletteStore? store}) async {
    final s = store ?? await PaletteStore.create();
    final service = PaletteService._(s);
    await service._load();
    final previous = _instance;
    if (previous != null && !identical(previous, service)) {
      previous.dispose();
    }
    _instance = service;
    return service;
  }

  @override
  void dispose() {
    _disposed = true;
    invalidatePaletteTextures();
    if (identical(_instance, this)) {
      _instance = null;
    }
    super.dispose();
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
    return _paletteTextures.paletteTexture(palette);
  }

  /// Returns a palette texture blended from index N into N+1 by fractional part.
  ui.Image paletteTextureForIndex(double index, {int colorCount = 64}) {
    return _paletteTextures.paletteTextureForIndex(
      index,
      paletteAtIndex,
      colorCount: colorCount,
    );
  }

  /// Clears cached palette textures (call if palettes change).
  void invalidatePaletteTextures() {
    _paletteTextures.clear();
  }

  Future<void> _commitUserPalettes(List<FractalPalette> palettes) async {
    _user = palettes;
    invalidatePaletteTextures();
    await _store.savePalettes(_user);
    _notifyIfAlive();
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
      FractalPalette(
        id: 'builtin_phoenix',
        name: 'Phoenix',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF120812),
          FractalColorStop(position: 0.28, colorArgb: 0xFF5B1237),
          FractalColorStop(position: 0.58, colorArgb: 0xFFE85D04),
          FractalColorStop(position: 0.82, colorArgb: 0xFFFFBA08),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFF3B0),
        ],
      ),
      FractalPalette(
        id: 'builtin_viridis_depth',
        name: 'Viridis Depth',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF440154),
          FractalColorStop(position: 0.25, colorArgb: 0xFF3B528B),
          FractalColorStop(position: 0.5, colorArgb: 0xFF21918C),
          FractalColorStop(position: 0.75, colorArgb: 0xFF5EC962),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFDE725),
        ],
      ),
      FractalPalette(
        id: 'builtin_magma_core',
        name: 'Magma Core',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF000004),
          FractalColorStop(position: 0.2, colorArgb: 0xFF3B0F70),
          FractalColorStop(position: 0.4, colorArgb: 0xFF8C2981),
          FractalColorStop(position: 0.62, colorArgb: 0xFFDE4968),
          FractalColorStop(position: 0.82, colorArgb: 0xFFFE9F6D),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFCFDBF),
        ],
      ),
      FractalPalette(
        id: 'builtin_cividis_safe',
        name: 'Cividis Safe',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF00204C),
          FractalColorStop(position: 0.22, colorArgb: 0xFF31446B),
          FractalColorStop(position: 0.45, colorArgb: 0xFF666870),
          FractalColorStop(position: 0.68, colorArgb: 0xFF958F78),
          FractalColorStop(position: 0.85, colorArgb: 0xFFC7B37B),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFE945),
        ],
      ),
      FractalPalette(
        id: 'builtin_perceptual_rainbow',
        name: 'Perceptual Rainbow',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF1B1B6F),
          FractalColorStop(position: 0.17, colorArgb: 0xFF4B3F9F),
          FractalColorStop(position: 0.34, colorArgb: 0xFFB23A8B),
          FractalColorStop(position: 0.51, colorArgb: 0xFFE05A47),
          FractalColorStop(position: 0.68, colorArgb: 0xFFE7A43B),
          FractalColorStop(position: 0.84, colorArgb: 0xFF78B94A),
          FractalColorStop(position: 1.0, colorArgb: 0xFF1FA7A8),
        ],
      ),
      FractalPalette(
        id: 'builtin_warm_cool_relief',
        name: 'Warm Cool Relief',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF172554),
          FractalColorStop(position: 0.25, colorArgb: 0xFF0EA5E9),
          FractalColorStop(position: 0.5, colorArgb: 0xFFF8FAFC),
          FractalColorStop(position: 0.75, colorArgb: 0xFFF97316),
          FractalColorStop(position: 1.0, colorArgb: 0xFF7F1D1D),
        ],
      ),
      FractalPalette(
        id: 'builtin_blue_yellow_opponent',
        name: 'Blue Yellow Opponent',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF081D58),
          FractalColorStop(position: 0.35, colorArgb: 0xFF2B8CBE),
          FractalColorStop(position: 0.5, colorArgb: 0xFFF7F7F7),
          FractalColorStop(position: 0.7, colorArgb: 0xFFFEE391),
          FractalColorStop(position: 1.0, colorArgb: 0xFFB15928),
        ],
      ),
      FractalPalette(
        id: 'builtin_high_contrast_mono',
        name: 'High Contrast Mono',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
          FractalColorStop(position: 0.18, colorArgb: 0xFF151515),
          FractalColorStop(position: 0.38, colorArgb: 0xFF3E3E3E),
          FractalColorStop(position: 0.65, colorArgb: 0xFF8A8A8A),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
        ],
      ),
      FractalPalette(
        id: 'builtin_colorblind_safe_fire',
        name: 'Colorblind Safe Fire',
        isBuiltIn: true,
        stops: [
          FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
          FractalColorStop(position: 0.2, colorArgb: 0xFF0072B2),
          FractalColorStop(position: 0.42, colorArgb: 0xFFD55E00),
          FractalColorStop(position: 0.65, colorArgb: 0xFFE69F00),
          FractalColorStop(position: 0.82, colorArgb: 0xFFF0E442),
          FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
        ],
      ),
      for (var i = 13; i < 64; i++) _generatedPalette(i),
    ];
  }

  static const List<String> _proceduralPaletteNames = [
    'Viridis Depth',
    'Magma Core',
    'Cividis Safe',
    'Perceptual Rainbow',
    'Warm Cool Relief',
    'Blue Yellow Opponent',
    'High Contrast Mono',
    'Colorblind Safe Fire',
    'Glacier Mint',
    'Solar Flare',
    'Ultraviolet',
    'Cyan Furnace',
    'Amber Circuit',
    'Plasma Wave',
    'Forest Lumen',
    'Ruby Ice',
    'Electric Dusk',
    'Golden Orbit',
    'Teal Comet',
    'Crimson Tide',
    'Lime Halo',
    'Indigo Ember',
    'Tangerine Sky',
    'Arctic Fire',
    'Magenta Bloom',
    'Blue Steel',
    'Opal Pulse',
    'Saffron Smoke',
    'Jade Signal',
    'Coral Eclipse',
    'Sonic Violet',
    'Bronze Aurora',
    'Cerulean Ash',
    'Pink Lightning',
    'Green Inferno',
    'Royal Plasma',
    'Desert Neon',
    'Ice Sapphire',
    'Infrared Moss',
    'Pearl Shadow',
    'Signal Orange',
    'Deep Orchid',
    'Aqua Gold',
    'Volcanic Glass',
    'Starlight Candy',
  ];

  static const List<String> _reliefBasePaletteNames = [
    'Fire',
    'Ocean',
    'Psychedelic',
    'Grayscale',
  ];

  static FractalPalette _generatedPalette(int index) {
    final name = _generatedPaletteName(index);
    final hue = ((index * 47) % 360).toDouble();
    final id =
        'builtin_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_$'), '')}';
    return FractalPalette(
      id: id,
      name: name,
      isBuiltIn: true,
      stops: [
        FractalColorStop(position: 0.0, colorArgb: _hsv(hue + 25, 0.85, 0.08)),
        FractalColorStop(position: 0.28, colorArgb: _hsv(hue, 0.82, 0.35)),
        FractalColorStop(position: 0.58, colorArgb: _hsv(hue + 35, 0.78, 0.72)),
        FractalColorStop(position: 1.0, colorArgb: _hsv(hue + 70, 0.55, 1.0)),
      ],
    );
  }

  static String _generatedPaletteName(int index) {
    if (index >= 5 && index < 50) {
      return _proceduralPaletteNames[index - 5];
    }
    final angle = (((index - 50) * 180) / 13).round();
    final baseName = _reliefBasePaletteNames[(index - 50) % 4];
    return 'Relief $angle° $baseName';
  }

  static int _hsv(double hue, double saturation, double value) {
    return HSVColor.fromAHSV(1, hue % 360, saturation, value)
        .toColor()
        .toARGB32();
  }
}

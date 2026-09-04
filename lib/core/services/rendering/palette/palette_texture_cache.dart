import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';

/// Owns reusable palette textures, including transient animation blends.
///
/// Returned images are borrowed: bind immediately, or clone and dispose the
/// clone if retaining a handle across cache calls. Already-bound shaders retain
/// their native image reference when a cache handle is evicted.
class PaletteTextureCache {
  static const int textureWidth = 256;
  // 256 KiB of RGBA texels, excluding backend allocation overhead and images
  // retained by active shaders. Keeps a transition's working set bounded.
  static const int maxEntries = 256;
  final Map<String, ui.Image> _cache = {};

  ui.Image? _get(String key) {
    final image = _cache.remove(key);
    if (image != null) _cache[key] = image;
    return image;
  }

  ui.Image _store(String key, ui.Image image) {
    if (_cache.length >= maxEntries) {
      _cache.remove(_cache.keys.first)!.dispose();
    }
    _cache[key] = image;
    return image;
  }

  ui.Image paletteTexture(FractalPalette palette, {int colorCount = 64}) {
    final count = colorCount.clamp(2, 64);
    final key = 'palette:${palette.id}:$count';
    final cached = _get(key);
    if (cached != null) return cached;

    final stops = normalizeFractalPaletteStops(palette.stops);
    return _store(
      key,
      _drawPaletteTexture(
        (t) => _colorAt(stops, t),
        colorCount: count,
      ),
    );
  }

  ui.Image paletteTextureForIndex(
    double index,
    FractalPalette Function(int index) paletteAtIndex, {
    int colorCount = 64,
  }) {
    final count = colorCount.clamp(2, 64);
    final from = index.floor();
    final mix256 = ((index - from) * 256).round().clamp(0, 256);
    final a = paletteAtIndex(from);
    if (mix256 == 0) return paletteTexture(a, colorCount: count);

    final b = paletteAtIndex(from + 1);
    if (mix256 == 256) return paletteTexture(b, colorCount: count);
    final key = 'blend:${a.id}:${b.id}:$mix256:$count';
    final cached = _get(key);
    if (cached != null) return cached;

    final t = mix256 / 256.0;
    final stopsA = normalizeFractalPaletteStops(a.stops);
    final stopsB = normalizeFractalPaletteStops(b.stops);
    // Sample the original gradients so narrow highlights survive transitions.
    return _store(
      key,
      _drawPaletteTexture(
        (position) => Color.lerp(
          _colorAt(stopsA, position),
          _colorAt(stopsB, position),
          t,
        )!,
        colorCount: count,
      ),
    );
  }

  void clear() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }

  ui.Image _drawPaletteTexture(
    Color Function(double) colorAt, {
    required int colorCount,
  }) {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(
      rec,
      Rect.fromLTWH(0, 0, textureWidth.toDouble(), 1),
    );
    final paint = Paint();
    var start = 0;
    var band = 0;
    for (var x = 1; x <= textureWidth; x++) {
      // Preserve the original floating-point band boundaries, including the
      // final pixel. Integer division differs at count=51, pixel=155.
      final nextBand = x == textureWidth
          ? colorCount
          : (x / (textureWidth - 1) * colorCount)
              .floor()
              .clamp(0, colorCount - 1);
      if (nextBand == band) continue;
      // Each band is constant: sample and draw it once instead of per pixel.
      paint.color = colorAt((band + 0.5) / colorCount);
      canvas.drawRect(
        Rect.fromLTWH(start.toDouble(), 0, (x - start).toDouble(), 1),
        paint,
      );
      start = x;
      band = nextBand;
    }
    final picture = rec.endRecording();
    try {
      return picture.toImageSync(textureWidth, 1);
    } finally {
      picture.dispose();
    }
  }

  Color _colorAt(List<FractalColorStop> stops, double t) {
    for (var i = 1; i < stops.length; i++) {
      final next = stops[i];
      if (t <= next.position) {
        final prev = stops[i - 1];
        final span = next.position - prev.position;
        final localT = span <= 0 ? 0.0 : (t - prev.position) / span;
        return Color.lerp(prev.color, next.color, localT)!;
      }
    }
    return stops.last.color;
  }
}

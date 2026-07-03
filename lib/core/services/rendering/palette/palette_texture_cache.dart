import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';

class PaletteTextureCache {
  static const int textureWidth = 256;
  final Map<String, ui.Image> _cache = {};

  ui.Image paletteTexture(FractalPalette palette, {int colorCount = 64}) {
    final count = colorCount.clamp(2, 64);
    final key = 'palette:${palette.id}:$count';
    final cached = _cache[key];
    if (cached != null) return cached;

    return _cache[key] = _drawPaletteTexture(
      normalizeFractalPaletteStops(palette.stops),
      colorCount: count,
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
    final key = 'blend:${a.id}:${b.id}:$mix256:$count';
    final cached = _cache[key];
    if (cached != null) return cached;

    final t = mix256 / 256.0;
    final stopsA = normalizeFractalPaletteStops(a.stops);
    final stopsB = normalizeFractalPaletteStops(b.stops);
    final stops = [
      for (var i = 0; i < maxFractalPaletteStops; i++)
        FractalColorStop(
          position: i / (maxFractalPaletteStops - 1),
          colorArgb: Color.lerp(
            _colorAt(stopsA, i / (maxFractalPaletteStops - 1)),
            _colorAt(stopsB, i / (maxFractalPaletteStops - 1)),
            t,
          )!
              .toARGB32(),
        ),
    ];
    return _cache[key] = _drawPaletteTexture(stops, colorCount: count);
  }

  void clear() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }

  ui.Image _drawPaletteTexture(
    List<FractalColorStop> stops, {
    required int colorCount,
  }) {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(
      rec,
      Rect.fromLTWH(0, 0, textureWidth.toDouble(), 1),
    );
    final paint = Paint();
    for (var x = 0; x < textureWidth; x++) {
      final t = x / (textureWidth - 1);
      final band = (t * colorCount).floor().clamp(0, colorCount - 1);
      final sampled =
          colorCount >= textureWidth ? t : (band + 0.5) / colorCount;
      paint.color = _colorAt(stops, sampled.clamp(0.0, 1.0));
      canvas.drawRect(Rect.fromLTWH(x.toDouble(), 0, 1, 1), paint);
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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';

class PaletteShaderAdapter {
  PaletteShaderAdapter._();

  static final PaletteShaderAdapter instance = PaletteShaderAdapter._();

  ui.Image? _fallbackSamplerTexture;

  void bindSamplerPalette(
    ui.FragmentShader shader,
    int samplerIndex,
    double colorScheme, {
    int colorCount = 64,
  }) {
    shader.setImageSampler(
      samplerIndex,
      samplerPaletteTexture(colorScheme, colorCount: colorCount),
    );
  }

  ui.Image samplerPaletteTexture(double colorScheme, {int colorCount = 64}) {
    try {
      return PaletteService.instance.paletteTextureForIndex(
        colorScheme,
        colorCount: colorCount,
      );
    } catch (_) {
      return _fallbackSamplerTexture ??= _createFallbackSamplerTexture();
    }
  }

  void bindUniformPalette(
    ui.FragmentShader shader,
    int baseIndex,
    double colorScheme,
  ) {
    try {
      final palette =
          PaletteService.instance.paletteAtIndex(colorScheme.round());
      _setCustomPaletteUniforms(shader, baseIndex, palette);
    } catch (_) {
      // PaletteService unavailable; shader built-in color schemes apply.
    }
  }

  /// Writes custom palette uniforms expected by the shaders.
  ///
  /// Layout:
  /// - [baseIndex + 0] = stopCount
  /// - then 8 vec4 stops, each: r, g, b, position
  void _setCustomPaletteUniforms(
    ui.FragmentShader shader,
    int baseIndex,
    FractalPalette palette,
  ) {
    final stops = normalizePaletteStops(palette.stops);
    final count = stops.length.clamp(0, PaletteService.maxStops);
    shader.setFloat(baseIndex, count.toDouble());

    // Fill remaining with last stop to avoid NaNs in shader.
    final padded = [...stops];
    while (padded.length < PaletteService.maxStops) {
      padded.add(padded.last);
    }

    for (var i = 0; i < PaletteService.maxStops; i++) {
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

  ui.Image _createFallbackSamplerTexture() {
    final rec = ui.PictureRecorder();
    final canvas = ui.Canvas(rec);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0xFF000000),
    );
    final picture = rec.endRecording();
    try {
      return picture.toImageSync(1, 1);
    } finally {
      picture.dispose();
    }
  }
}

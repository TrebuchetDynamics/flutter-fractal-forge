import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';

/// Materialized display colours only. Exact residues and the zero mask never
/// travel through floating point, including for primes beyond JavaScript ints.
class NumberWallStyle {
  NumberWallStyle._(this.mode, this.foreground, this.zero, this.background,
      this.showGrid, List<Color> palette)
      : palette = List.unmodifiable(palette);

  factory NumberWallStyle.fromParams(Map<String, Object> params) {
    final scheme = (params['colorScheme'] as num?)?.toInt() ?? 0;
    List<FractalColorStop>? stops;
    try {
      stops = normalizePaletteStops(
          PaletteService.instance.paletteAtIndex(scheme).stops);
    } on StateError {
      // Preserve a deterministic palette before the app service is available.
    }
    Color sample(int index) {
      if (stops == null) {
        return HSVColor.fromAHSV(1, ((index + scheme * 41) % 360).toDouble(),
                0.72, 0.38 + 0.48 * index / 255)
            .toColor();
      }
      final t = index / 255;
      final right =
          stops.firstWhere((s) => s.position >= t, orElse: () => stops!.last);
      final left =
          stops.lastWhere((s) => s.position <= t, orElse: () => stops!.first);
      return Color.lerp(
              left.color,
              right.color,
              right.position == left.position
                  ? 0
                  : (t - left.position) / (right.position - left.position))!
          .withValues(alpha: 1);
    }

    Color color(String id, int fallback) =>
        Color(0xff000000 | ((params[id] as num?)?.toInt() ?? fallback));
    return NumberWallStyle._(
      (params['colorMode'] as num?)?.toInt() ?? 0,
      color('foregroundColor', 0x20283b),
      color('zeroColor', 0xf4c95d),
      color('backgroundColor', 0x090b12),
      params['showGrid'] == true,
      List.generate(256, sample),
    );
  }

  final int mode;
  final Color foreground, zero, background;
  final bool showGrid;
  final List<Color> palette;

  String get key => '$mode|${foreground.toARGB32()}|${zero.toARGB32()}|'
      '${background.toARGB32()}|$showGrid|${palette.map((c) => c.toARGB32()).join(',')}';

  Color cellColor(BigInt value, BigInt prime) {
    if (value == BigInt.zero) return zero;
    final color = mode == 0
        ? foreground
        : palette[(value * BigInt.from(palette.length) ~/ prime)
            .toInt()
            .clamp(0, palette.length - 1)];
    // A low nonzero residue may share bin zero, but never its divisibility ink.
    return color == zero
        ? Color(0xff000000 | (zero.toARGB32() ^ 0x00ffffff))
        : color;
  }
}

Rect numberWallFieldRect(Size size, FractalViewState view) => Rect.fromCenter(
    center: Offset(
        size.width / 2 * (1 + view.pan.x), size.height / 2 * (1 + view.pan.y)),
    width: size.width * view.zoom.clamp(0.25, 16),
    height: size.height * view.zoom.clamp(0.25, 16));

/// Shared exact-grid rasterizer for Canvas, sampler display and offscreen PNG.
class NumberWallPainter extends CustomPainter {
  const NumberWallPainter(
      {required this.grid,
      required this.style,
      required this.view,
      this.transparentBackground = false,
      this.image,
      this.shader});

  final NumberWallGrid grid;
  final NumberWallStyle style;
  final FractalViewState view;
  final bool transparentBackground;
  final ui.Image? image;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (!transparentBackground) {
      canvas.drawRect(Offset.zero & size, Paint()..color = style.background);
    }
    final rect = numberWallFieldRect(size, view);
    final shader = this.shader;
    if (shader != null && image != null) {
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, grid.columnCount.toDouble())
        ..setFloat(3, grid.rowCount.toDouble())
        ..setFloat(4, rect.left)
        ..setFloat(5, rect.top)
        ..setFloat(6, rect.width)
        ..setFloat(7, rect.height)
        ..setImageSampler(0, image!);
      canvas.drawRect(
          rect,
          Paint()
            ..shader = shader
            ..isAntiAlias = false);
    } else {
      final paint = Paint()..isAntiAlias = false;
      for (var row = 0; row < grid.rowCount; row++) {
        for (var column = 0; column < grid.columnCount; column++) {
          paint.color = style.cellColor(grid.values[row][column], grid.prime);
          canvas.drawRect(
              Rect.fromLTRB(
                  rect.left + column * rect.width / grid.columnCount,
                  rect.top + row * rect.height / grid.rowCount,
                  rect.left + (column + 1) * rect.width / grid.columnCount,
                  rect.top + (row + 1) * rect.height / grid.rowCount),
              paint);
        }
      }
    }
    if (style.showGrid) {
      final paint = Paint()
        ..color = style.background
        ..isAntiAlias = false
        ..strokeWidth = 1;
      for (var col = 0; col <= grid.columnCount; col++) {
        final x = rect.left + col * rect.width / grid.columnCount;
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
      }
      for (var row = 0; row <= grid.rowCount; row++) {
        final y = rect.top + row * rect.height / grid.rowCount;
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NumberWallPainter old) =>
      old.grid != grid ||
      old.style.key != style.key ||
      old.view != view ||
      old.transparentBackground != transparentBackground ||
      old.image != image ||
      old.shader != shader;
}

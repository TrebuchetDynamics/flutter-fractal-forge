import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/constants/thumbnail_colors.dart';

/// {@template thumbnail_gradient_fallback}
/// A category-aware gradient fallback widget for fractal thumbnails.
///
/// This widget provides visually distinct gradient-based fallbacks when
/// thumbnail images are not available. It uses a [CustomPainter] to render
/// category-appropriate gradients based on the fractal type.
///
/// ## Supported Categories
///
/// - **Escape-Time**: Deep blue/purple with radial glow
/// - **Complex Visualization**: Rainbow/spectrum sweep
/// - **Rational Maps**: Warm red/orange gradients
/// - **Attractors**: Green/teal gradients
/// - **Cellular Automata**: Monochrome geometric patterns
/// - **Default**: HSV-based gradients with depth
///
/// ## Usage
///
/// ```dart
/// ThumbnailGradientFallback(
///   catalogId: 'core.mandelbrot',
///   category: 'Escape-Time',
/// )
/// ```
///
/// The widget is stateless and uses [catalogId.hashCode] to generate
/// deterministic variations within each category, ensuring the same
/// fractal always renders the same fallback pattern.
/// {@endtemplate}
class ThumbnailGradientFallback extends StatelessWidget {
  /// Unique identifier for the catalog entry.
  ///
  /// Used to generate deterministic visual variations via hashCode.
  final String catalogId;

  /// Category name for selecting the appropriate gradient style.
  ///
  /// Case-insensitive. Supports: 'escape', 'complex', 'rational',
  /// 'attract', 'cellular', 'automata', and default fallback.
  final String category;

  /// Creates a thumbnail gradient fallback widget.
  ///
  /// Both [catalogId] and [category] are required. The [catalogId] provides
  /// deterministic variation while [category] determines the color scheme.
  const ThumbnailGradientFallback({
    super.key,
    required this.catalogId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ThumbnailFractalGradientPainter(
        catalogId: catalogId,
        category: category,
      ),
    );
  }
}

/// {@template thumbnail_fractal_gradient_painter}
/// Custom painter that renders category-specific gradient patterns.
///
/// This painter is used internally by [ThumbnailGradientFallback] to render
/// the actual gradient graphics. It dispatches to one of six specialized
/// painting methods based on the category.
/// {@endtemplate}
class ThumbnailFractalGradientPainter extends CustomPainter {
  /// Unique identifier for deterministic variation generation.
  final String catalogId;

  /// Category for selecting the painting style.
  final String category;

  /// Creates a gradient painter.
  ///
  /// The [catalogId] and [category] are used to determine the visual output.
  const ThumbnailFractalGradientPainter({
    required this.catalogId,
    required this.category,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cat = category.toLowerCase();
    final hash = catalogId.hashCode.abs();

    if (cat.contains('escape')) {
      _paintEscapeTime(canvas, rect, hash);
    } else if (cat.contains('complex')) {
      _paintComplexViz(canvas, rect, hash);
    } else if (cat.contains('rational')) {
      _paintRationalMaps(canvas, rect, hash);
    } else if (cat.contains('attract')) {
      _paintAttractors(canvas, rect, hash);
    } else if (cat.contains('cellular') || cat.contains('automata')) {
      _paintCellular(canvas, rect, hash);
    } else {
      _paintDefault(canvas, rect, hash);
    }
  }

  /// Deep blue/purple with radial glow (Escape-Time fractals).
  void _paintEscapeTime(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(
        rect, Paint()..color = ThumbnailColors.escapeTimeBackground);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            ThumbnailColors.escapeTimeGlowCenter,
            ThumbnailColors.escapeTimeGlowMid,
            ThumbnailColors.escapeTimeGlowEdge,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final offsetX = (hash % 40 - 20) / 60.0;
    final offsetY = ((hash ~/ 37) % 40 - 20) / 60.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(offsetX, offsetY),
          radius: 0.38,
          colors: const [
            ThumbnailColors.escapeTimeAccentCenter,
            ThumbnailColors.escapeTimeAccentMid,
            ThumbnailColors.escapeTimeAccentEdge,
          ],
        ).createShader(rect),
    );

    final angle = (hash % 60).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(angle),
          colors: [
            ThumbnailColors.escapeTimeSweepStart,
            ThumbnailColors.escapeTimeSweepMid,
            ThumbnailColors.escapeTimeSweepEnd,
          ],
        ).createShader(rect),
    );
  }

  /// Rainbow/spectrum sweep (Complex Visualization).
  void _paintComplexViz(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(
        rect, Paint()..color = ThumbnailColors.complexVizBackground);

    final sweepAngle = (hash % 45).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(sweepAngle),
          colors: [
            ThumbnailColors.complexVizPink,
            ThumbnailColors.complexVizOrange,
            ThumbnailColors.complexVizYellow,
            ThumbnailColors.complexVizGreen,
            ThumbnailColors.complexVizBlue,
            ThumbnailColors.complexVizPurple,
            ThumbnailColors.complexVizPink,
          ],
          stops: const [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.85,
          colors: [
            ThumbnailColors.complexVizVignetteTransparent,
            ThumbnailColors.complexVizVignetteDark,
          ],
        ).createShader(rect),
    );
  }

  /// Warm red/orange (Rational Maps).
  void _paintRationalMaps(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(
        rect, Paint()..color = ThumbnailColors.rationalMapsBackground);

    final cx = (hash % 30 - 20) / 40.0;
    final cy = ((hash ~/ 31) % 30 - 20) / 40.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.85,
          colors: const [
            ThumbnailColors.rationalMapsGlowCenter,
            ThumbnailColors.rationalMapsGlowMid,
            ThumbnailColors.rationalMapsGlowEdge,
          ],
          stops: [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ThumbnailColors.rationalMapsAccentStart,
            ThumbnailColors.rationalMapsAccentMid,
            ThumbnailColors.rationalMapsAccentEnd,
          ],
        ).createShader(rect),
    );
  }

  /// Green/teal (Attractors).
  void _paintAttractors(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = ThumbnailColors.attractorBackground);

    final cx = (hash % 40 - 20) / 50.0;
    final cy = ((hash ~/ 41) % 40 - 20) / 50.0;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(cx, cy),
          radius: 0.9,
          colors: const [
            ThumbnailColors.attractorGlowCenter,
            ThumbnailColors.attractorGlowMid,
            ThumbnailColors.attractorGlowEdge,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThumbnailColors.attractorAccentStart,
            ThumbnailColors.attractorAccentMid,
            ThumbnailColors.attractorAccentEnd,
          ],
        ).createShader(rect),
    );
  }

  /// Monochrome geometric (Cellular Automata).
  void _paintCellular(Canvas canvas, Rect rect, int hash) {
    canvas.drawRect(rect, Paint()..color = ThumbnailColors.cellularBackground);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThumbnailColors.cellularGradientTop,
            ThumbnailColors.cellularGradientBottom,
          ],
        ).createShader(rect),
    );

    final linePaint = Paint()
      ..color = ThumbnailColors.cellularGridLine
      ..strokeWidth = 0.8;

    final step = 8.0 + (hash % 6).toDouble();
    for (double x = 0; x < rect.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, rect.height), linePaint);
    }
    for (double y = 0; y < rect.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(rect.width, y), linePaint);
    }

    final accentPaint = Paint()..color = ThumbnailColors.cellularAccent;
    final cols = (rect.width / step).floor();
    final rows = (rect.height / step).floor();
    if (cols > 0 && rows > 0) {
      for (int i = 0; i < 6; i++) {
        final col = ((hash ~/ math.pow(3, i).toInt()) % cols).toDouble() * step;
        final row = ((hash ~/ math.pow(5, i).toInt()) % rows).toDouble() * step;
        canvas.drawRect(
            Rect.fromLTWH(col, row, step - 1, step - 1), accentPaint);
      }
    }
  }

  /// Default — HSV-based with overlapping gradients for depth.
  void _paintDefault(Canvas canvas, Rect rect, int hash) {
    final hueA = (hash % 360).toDouble();
    final hueB = ((hash ~/ 11) % 360).toDouble();
    final colorA = HSVColor.fromAHSV(1, hueA, 0.58, 0.92).toColor();
    final colorB = HSVColor.fromAHSV(1, hueB, 0.66, 0.78).toColor();
    final colorMid =
        HSVColor.fromAHSV(1, (hueA + hueB) / 2, 0.72, 0.55).toColor();

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA, colorB],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [
            colorMid.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    final angle = (hash % 90).toDouble() * math.pi / 180;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          transform: GradientRotation(angle),
          colors: [
            colorB.withValues(alpha: 0.4),
            Colors.transparent,
            colorA.withValues(alpha: 0.3),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(ThumbnailFractalGradientPainter old) =>
      old.catalogId != catalogId || old.category != category;
}

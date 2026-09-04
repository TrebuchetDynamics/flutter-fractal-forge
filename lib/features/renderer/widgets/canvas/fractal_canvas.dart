import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class FractalCanvas extends CustomPainter {
  final FractalModule module;
  final FractalRenderState state;
  final double time;
  final ui.FragmentShader shader;
  final bool glowEnabled;
  final double glowSigma;
  final double glowIntensity;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final double kaleidoscopeRotation;
  final int kaleidoscopeMirrorMode;

  FractalCanvas({
    required this.module,
    required this.state,
    required this.time,
    required this.shader,
    this.glowEnabled = false,
    this.glowSigma = 1.0,
    this.glowIntensity = 0.35,
    this.kaleidoscopeEnabled = false,
    this.kaleidoscopeSectors = 8,
    this.kaleidoscopeMirror = true,
    this.kaleidoscopeRotation = 0.0,
    this.kaleidoscopeMirrorMode = 0,
  });

  /// Returns the reflection scale for one kaleidoscope sector.
  static Offset kaleidoscopeSectorScale({
    required bool mirror,
    required int mode,
    required int sector,
  }) {
    if (!mirror) return const Offset(1.0, 1.0);
    if (mode == 0 && sector.isEven) return const Offset(-1.0, 1.0);
    if (mode == 1) return const Offset(-1.0, 1.0);
    if (mode == 2) {
      final m = sector % 3;
      if (m == 1) return const Offset(-1.0, 1.0);
      if (m == 2) return const Offset(1.0, -1.0);
    }
    return const Offset(1.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    module.setUniforms(shader, state, size, time);

    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    // Base fractal (kaleidoscoped or plain).
    _paintFractal(canvas, size, basePaint);

    // Glow is a blurred, screen-blended copy of the SAME fractal content, so it
    // follows the kaleidoscope tiling instead of leaking the un-mirrored image.
    // The blur lives on the saveLayer so the whole composite is blurred as one,
    // which also avoids per-wedge clip seams.
    if (glowEnabled && glowIntensity > 0.0) {
      // Map the controller's glowSigma range [0.1, 5.0] linearly onto a blur
      // sigma of [2, 48]. A flat `glowSigma * 8` left the bottom of the slider
      // (<=0.25) flattened to the clamp floor and never reached the ceiling.
      final s = glowSigma.clamp(0.1, 5.0);
      final sigma = 2.0 + (s - 0.1) * (46.0 / 4.9);
      canvas.saveLayer(
        rect,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = Color.fromRGBO(255, 255, 255, glowIntensity.clamp(0.0, 1.0))
          ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      );
      _paintFractal(canvas, size, basePaint);
      canvas.restore();
    }
  }

  /// Paints the fractal with [paint] across the canvas, applying the
  /// kaleidoscope wedge tiling when enabled. Shared by the base pass and the
  /// glow pass so the glow matches the on-screen geometry exactly.
  void _paintFractal(Canvas canvas, Size size, Paint paint) {
    if (!kaleidoscopeEnabled) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    final int sectors = kaleidoscopeSectors;
    final double rot = kaleidoscopeRotation;
    final int mode = kaleidoscopeMirrorMode;
    final center = Offset(size.width / 2, size.height / 2);
    // Radius large enough to cover every corner of the screen from any point.
    final double diagRadius =
        math.sqrt(size.width * size.width + size.height * size.height) * 2.0;
    final double sectorAngle = 2 * math.pi / sectors;

    // Share exact destination endpoints between adjacent sectors. Independently
    // transformed clip edges can round apart and leave single-pixel holes.
    // At the supported 4–16 sectors this radius also keeps each triangle's
    // outer chord beyond every viewport corner.
    final edges = List<Offset>.generate(sectors, (i) {
      final angle = rot + (i - 0.5) * sectorAngle;
      return center + Offset(math.cos(angle), math.sin(angle)) * diagRadius;
    });
    final wedgePath = Path();
    final fillRect = Rect.fromCenter(
      center: center,
      width: diagRadius * 4,
      height: diagRadius * 4,
    );

    for (int i = 0; i < sectors; i++) {
      canvas.save();
      // Clip the destination sector before reflecting its content. Reflecting
      // the clip too moves wedges to the opposite side, causing holes and
      // overlaps (notably with 6, 10 or 14 sectors in alternating mode).
      // Adjacent wedges tile the surface: independently antialiasing their
      // shared edges would leave translucent hairlines in opaque artwork.
      final start = edges[i];
      final end = edges[(i + 1) % sectors];
      wedgePath
        ..reset()
        ..moveTo(center.dx, center.dy)
        ..lineTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy)
        ..close();
      canvas.clipPath(wedgePath, doAntiAlias: false);

      final scale = kaleidoscopeSectorScale(
        mirror: kaleidoscopeMirror,
        mode: mode,
        sector: i,
      );
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rot + i * sectorAngle);
      canvas.scale(scale.dx, scale.dy);
      canvas.translate(-center.dx, -center.dy);

      // Rect large enough to fill the clip region regardless of canvas rotation.
      canvas.drawRect(fillRect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FractalCanvas oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.time != time ||
        oldDelegate.shader != shader ||
        oldDelegate.module.id != module.id ||
        oldDelegate.glowEnabled != glowEnabled ||
        oldDelegate.glowSigma != glowSigma ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.kaleidoscopeEnabled != kaleidoscopeEnabled ||
        oldDelegate.kaleidoscopeSectors != kaleidoscopeSectors ||
        oldDelegate.kaleidoscopeMirror != kaleidoscopeMirror ||
        oldDelegate.kaleidoscopeRotation != kaleidoscopeRotation ||
        oldDelegate.kaleidoscopeMirrorMode != kaleidoscopeMirrorMode;
  }
}

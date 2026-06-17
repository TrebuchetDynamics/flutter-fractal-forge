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

  @override
  void paint(Canvas canvas, Size size) {
    module.setUniforms(shader, state, size, time);

    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    final bool kaleidoEnabled = kaleidoscopeEnabled;
    final int sectors = kaleidoscopeSectors;
    final double rot = kaleidoscopeRotation;
    final int mode = kaleidoscopeMirrorMode;

    if (kaleidoEnabled) {
      final center = Offset(size.width / 2, size.height / 2);
      // Use a radius large enough to cover every corner of the screen from any point
      final double diagRadius =
          math.sqrt(size.width * size.width + size.height * size.height) * 2.0;

      final double sectorAngle = 2 * math.pi / sectors;

      for (int i = 0; i < sectors; i++) {
        canvas.save();

        // Mover al centro
        canvas.translate(center.dx, center.dy);

        // Rotar al sector
        canvas.rotate(rot + i * sectorAngle);

        // Espejo según modo
        if (mode == 0) {
          if (i % 2 == 0) canvas.scale(-1.0, 1.0);
        } else if (mode == 1) {
          canvas.scale(-1.0, 1.0);
        } else if (mode == 2) {
          final m = i % 3;
          if (m == 1) canvas.scale(-1.0, 1.0);
          if (m == 2) canvas.scale(1.0, -1.0);
        }

        // Volver a coordenadas originales
        canvas.translate(-center.dx, -center.dy);

        // Cuña con arco: cubre exactamente 1/sectors de la pantalla
        final Path wedgePath = Path();
        wedgePath.moveTo(center.dx, center.dy);
        // Use arcTo so the outer edge follows a curve, not a straight chord
        final double startAngle = -sectorAngle / 2;
        final Rect arcRect =
            Rect.fromCircle(center: center, radius: diagRadius);
        wedgePath.lineTo(
          center.dx + diagRadius * math.cos(startAngle),
          center.dy + diagRadius * math.sin(startAngle),
        );
        wedgePath.arcTo(arcRect, startAngle, sectorAngle, false);
        wedgePath.close();

        canvas.save();
        canvas.clipPath(wedgePath);
        // Draw a rect large enough to fill the clip region regardless of canvas rotation.
        // The shader renders in screen-space so the fractal content is not affected.
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: diagRadius * 4,
            height: diagRadius * 4,
          ),
          basePaint,
        );
        canvas.restore();

        canvas.restore();
      }
    } else {
      canvas.drawRect(rect, basePaint);
    }

    if (glowEnabled && glowIntensity > 0.0) {
      final sigma = (glowSigma * 8.0).clamp(2.0, 48.0);
      canvas.saveLayer(
        rect,
        Paint()
          ..blendMode = BlendMode.screen
          ..color =
              Color.fromRGBO(255, 255, 255, glowIntensity.clamp(0.0, 1.0)),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.fill
          ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      );
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

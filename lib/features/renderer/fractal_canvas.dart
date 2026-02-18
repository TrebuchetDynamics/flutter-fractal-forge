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

  FractalCanvas({
    required this.module,
    required this.state,
    required this.time,
    required this.shader,
    this.glowEnabled = false,
    this.glowSigma = 1.0,
    this.glowIntensity = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    module.setUniforms(shader, state, size, time);

    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    // Draw the base fractal (always sharp).
    canvas.drawRect(rect, basePaint);

    // Glow: draw blurred version with screen blending on top.
    if (glowEnabled && glowIntensity > 0.0) {
      final sigma = (glowSigma * 8.0).clamp(2.0, 48.0);
      canvas.saveLayer(
        rect,
        Paint()..blendMode = BlendMode.screen,
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
        oldDelegate.glowIntensity != glowIntensity;
  }
}

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
    try {
      module.setUniforms(shader, state, size, time);
    } catch (e) {
      // Log uniform setting errors but don't crash the renderer
      debugPrint(
          '[fractal_canvas] Uniform setting failed for ${module.id}: $e');
      // Re-throw in debug mode to catch issues during development
      if (kDebugMode) {
        rethrow;
      }
      return;
    }

    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    // Draw the base fractal (always sharp).
    canvas.drawRect(rect, basePaint);

    // Glow: draw blurred version with screen blending on top.
    if (glowEnabled && glowIntensity > 0.0) {
      final sigma = (glowSigma * 8.0).clamp(2.0, 48.0);
      // Alpha controls glow brightness: glowIntensity=1.0 → full, 0.35 → subtle.
      canvas.saveLayer(
        rect,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = Color.fromARGB(
              (glowIntensity.clamp(0.0, 1.0) * 255).round(), 255, 255, 255),
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

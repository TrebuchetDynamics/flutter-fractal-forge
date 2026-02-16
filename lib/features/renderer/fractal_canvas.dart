import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class FractalCanvas extends CustomPainter {
  final FractalModule module;
  final FractalRenderState state;
  final double time;
  final FragmentShader shader;

  FractalCanvas({
    required this.module,
    required this.state,
    required this.time,
    required this.shader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    module.setUniforms(shader, state, size, time);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant FractalCanvas oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.time != time ||
        oldDelegate.shader != shader ||
        oldDelegate.module.id != module.id;
  }
}

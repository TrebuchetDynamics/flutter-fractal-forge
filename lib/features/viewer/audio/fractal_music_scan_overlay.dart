import 'dart:math' as math;

import 'package:flutter/material.dart';

class FractalMusicScanOverlay extends StatelessWidget {
  final Animation<double> animation;

  const FractalMusicScanOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => CustomPaint(
          painter: _FractalMusicScanPainter(animation.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _FractalMusicScanPainter extends CustomPainter {
  final double progress;

  const _FractalMusicScanPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = size.center(Offset.zero);
    final radius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final angle = progress * math.pi * 2 - math.pi / 2;
    final end = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);
    canvas.drawCircle(center, 4, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_FractalMusicScanPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

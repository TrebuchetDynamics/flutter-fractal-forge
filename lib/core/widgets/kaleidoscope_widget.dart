import 'dart:math' as math;
import 'package:flutter/material.dart';

typedef KaleidoscopePainterCallback = void Function(Canvas canvas, Size size);

class KaleidoscopePainter extends CustomPainter {
  final KaleidoscopePainterCallback paintCallback;
  final int sectors;
  final bool mirrorSectors;
  final double rotation;

  KaleidoscopePainter({
    required this.paintCallback,
    this.sectors = 8,
    this.mirrorSectors = true,
    this.rotation = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    canvas.restore();

    final sectorAngle = 2 * math.pi / sectors;

    for (int i = 0; i < sectors; i++) {
      canvas.save();

      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation + i * sectorAngle);

      if (mirrorSectors && i.isOdd) {
        canvas.scale(-1.0, 1.0);
      }

      canvas.translate(-center.dx, -center.dy);

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height / 2));
      paintCallback(canvas, size);
      canvas.restore();

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant KaleidoscopePainter oldDelegate) {
    return oldDelegate.sectors != sectors ||
        oldDelegate.mirrorSectors != mirrorSectors ||
        oldDelegate.rotation != rotation;
  }
}

class KaleidoscopeWidget extends StatelessWidget {
  final KaleidoscopePainterCallback paintCallback;
  final int sectors;
  final bool mirrorSectors;
  final double rotation;

  const KaleidoscopeWidget({
    super.key,
    required this.paintCallback,
    this.sectors = 8,
    this.mirrorSectors = true,
    this.rotation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: KaleidoscopePainter(
        paintCallback: paintCallback,
        sectors: sectors,
        mirrorSectors: mirrorSectors,
        rotation: rotation,
      ),
      size: Size.infinite,
    );
  }
}
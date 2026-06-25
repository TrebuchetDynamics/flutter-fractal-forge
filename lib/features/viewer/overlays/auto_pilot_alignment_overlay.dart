import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';

/// Shows an inverted crosshair while auto-pilot yields to touch input.
class AutoPilotAlignmentOverlay extends StatelessWidget {
  final AutoExploreService? service;

  const AutoPilotAlignmentOverlay({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final service = this.service;
    if (service == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        if (!service.pausedByUserCorrection) return const SizedBox.shrink();

        return IgnorePointer(
          child: Semantics(
            liveRegion: true,
            label: 'Auto-pilot paused. Align zoom with the center crosshair.',
            child: const RepaintBoundary(
              key: ValueKey('autoPilotAlignmentCrosshair'),
              child: Center(
                child: SizedBox(
                  width: 168,
                  height: 168,
                  child: CustomPaint(
                    painter: _InvertedCrosshairPainter(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InvertedCrosshairPainter extends CustomPainter {
  const _InvertedCrosshairPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final invertFill = Paint()
      ..blendMode = BlendMode.difference
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final invertStroke = Paint()
      ..blendMode = BlendMode.difference
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, invertFill);
    canvas.drawCircle(center, radius, invertStroke);
    canvas.drawLine(
      Offset(center.dx - radius - 18, center.dy),
      Offset(center.dx - 10, center.dy),
      invertStroke,
    );
    canvas.drawLine(
      Offset(center.dx + 10, center.dy),
      Offset(center.dx + radius + 18, center.dy),
      invertStroke,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 18),
      Offset(center.dx, center.dy - 10),
      invertStroke,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 10),
      Offset(center.dx, center.dy + radius + 18),
      invertStroke,
    );
    canvas.drawCircle(center, 4, invertStroke);
    canvas.drawCircle(center, radius + 8, accent);
  }

  @override
  bool shouldRepaint(covariant _InvertedCrosshairPainter oldDelegate) => false;
}

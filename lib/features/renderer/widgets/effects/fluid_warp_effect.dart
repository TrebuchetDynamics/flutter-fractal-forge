import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class FluidWarpEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double time;
  final Offset touchPosition;
  final double strength;
  final Offset touchVelocity;
  final Offset secondaryTouchPosition;
  final bool secondaryTouchActive;
  final bool touchActive;

  const FluidWarpEffect({
    super.key,
    required this.child,
    required this.enabled,
    required this.time,
    required this.touchPosition,
    this.strength = 1.0,
    this.touchVelocity = Offset.zero,
    this.secondaryTouchPosition = Offset.zero,
    this.secondaryTouchActive = false,
    required this.touchActive,
  });

  @override
  State<FluidWarpEffect> createState() => _FluidWarpEffectState();
}

class _FluidWarpEffectState extends State<FluidWarpEffect> {
  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram>? _load;
  ui.FragmentShader? _shader;
  double _touchEnergy = 0.0;

  @override
  void initState() {
    super.initState();
    _ensureProgram();
  }

  @override
  void didUpdateWidget(covariant FluidWarpEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dt = (widget.time - oldWidget.time).clamp(0.0, 100.0);
    if (widget.touchActive) {
      _touchEnergy = 1.0;
    } else if (dt > 0.0) {
      // Keep the last gesture alive briefly so a release leaves a fluid wake.
      _touchEnergy *= math.exp(-dt / 260.0);
    }
    if (widget.enabled) _ensureProgram();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _ensureProgram() async {
    if (!widget.enabled || !ui.ImageFilter.isShaderFilterSupported) return;
    if (_program != null) return;
    try {
      _load ??= ui.FragmentProgram.fromAsset('shaders/runtime/fluid_warp.frag');
      _program = await _load;
    } catch (e) {
      // ponytail: single attempt; re-toggle fluid mode to retry
      debugPrint('[fluid_warp] shader load failed: $e');
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.width.isFinite || !size.height.isFinite) return widget.child;
        final touchX =
            (widget.touchPosition.dx / size.width.clamp(1.0, double.infinity))
                .clamp(0.0, 1.0);
        final touchY =
            (widget.touchPosition.dy / size.height.clamp(1.0, double.infinity))
                .clamp(0.0, 1.0);
        final touchVelocityX =
            (widget.touchVelocity.dx / size.width.clamp(1.0, double.infinity))
                .clamp(-0.25, 0.25);
        final touchVelocityY =
            (widget.touchVelocity.dy / size.height.clamp(1.0, double.infinity))
                .clamp(-0.25, 0.25);
        final secondaryTouchX = (widget.secondaryTouchPosition.dx /
                size.width.clamp(1.0, double.infinity))
            .clamp(0.0, 1.0);
        final secondaryTouchY = (widget.secondaryTouchPosition.dy /
                size.height.clamp(1.0, double.infinity))
            .clamp(0.0, 1.0);

        Widget content = widget.child;
        if (ui.ImageFilter.isShaderFilterSupported && _program != null) {
          _shader = _program!.fragmentShader()
            ..setFloat(2, widget.time)
            ..setFloat(3, widget.strength.clamp(0.0, 2.0))
            ..setFloat(4, touchX)
            ..setFloat(5, touchY)
            ..setFloat(6, widget.touchActive ? 1.0 : 0.0)
            ..setFloat(7, _touchEnergy)
            ..setFloat(8, touchVelocityX)
            ..setFloat(9, touchVelocityY)
            ..setFloat(10, secondaryTouchX)
            ..setFloat(11, secondaryTouchY)
            ..setFloat(12, widget.secondaryTouchActive ? 1.0 : 0.0);
          content = ImageFiltered(
            imageFilter: ui.ImageFilter.shader(_shader!),
            child: CustomPaint(
              painter: const _FluidWarpBoundsPainter(),
              child: widget.child,
            ),
          );
        }

        return CustomPaint(
          foregroundPainter: _FluidPointerPainter(
            position: widget.touchPosition,
            active: widget.touchActive,
            time: widget.time,
          ),
          child: content,
        );
      },
    );
  }
}

class _FluidPointerPainter extends CustomPainter {
  final Offset position;
  final bool active;
  final double time;

  const _FluidPointerPainter({
    required this.position,
    required this.active,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final t = time * 0.006;
    final radius = 44.0 + (t % 1.0) * 22.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.cyanAccent.withValues(alpha: 0.45);
    canvas.drawCircle(position, radius, paint);
    canvas.drawCircle(
      position,
      radius * 0.55,
      paint..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _FluidPointerPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.active != active ||
      oldDelegate.time != time;
}

class _FluidWarpBoundsPainter extends CustomPainter {
  const _FluidWarpBoundsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(1, 0, 0, 0);
    canvas.drawPoints(
        ui.PointMode.points,
        [
          Offset.zero,
          Offset(size.width - 1, 0),
          Offset(0, size.height - 1),
          Offset(size.width - 1, size.height - 1),
        ],
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

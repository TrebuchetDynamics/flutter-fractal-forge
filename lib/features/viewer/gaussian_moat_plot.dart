import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/gaussian_moat_model.dart';

/// Matches the renderer's 2D normalized camera, with imaginary-positive upward.
class GaussianMapTransform {
  final Size size;
  final FractalViewState view;
  final int bound;
  const GaussianMapTransform(this.size, this.view, this.bound);

  double get _extent => 2.0 * (bound + 2);
  double get _scale => math.max(1.0, math.min(size.width, size.height));
  Offset get _center => Offset(size.width / 2, size.height / 2);

  Offset toScreen(Offset lattice) =>
      _center +
      Offset(lattice.dx / _extent - view.pan.x,
              -lattice.dy / _extent - view.pan.y) *
          (_scale * view.zoom);

  Offset toLattice(Offset screen) {
    final n = (screen - _center) / (_scale * view.zoom);
    return Offset(
        (n.dx + view.pan.x) * _extent, -(n.dy + view.pan.y) * _extent);
  }

  GaussianInteger pick(Offset screen) {
    final p = toLattice(screen);
    return (a: p.dx.round(), b: p.dy.round());
  }
}

class GaussianMoatPainter extends CustomPainter {
  final GaussianPrimeMap map;
  final FractalViewState view;
  final GaussianInteger root;
  final GaussianInteger? candidate;
  final Color foreground;
  final Color background;
  final Color highlight;
  const GaussianMoatPainter(
      {required this.map,
      required this.view,
      required this.root,
      required this.candidate,
      required this.foreground,
      required this.background,
      required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final transform = GaussianMapTransform(size, view, map.bound);
    Offset screen(GaussianInteger p) =>
        transform.toScreen(Offset(p.a.toDouble(), p.b.toDouble()));
    canvas.clipRect(Offset.zero & size);
    canvas.drawColor(background, BlendMode.src);
    final domain = Rect.fromPoints(
      transform.toScreen(Offset(-map.bound - 0.5, -map.bound - 0.5)),
      transform.toScreen(Offset(map.bound + 0.5, map.bound + 0.5)),
    );
    canvas.drawRect(
        domain, Paint()..color = foreground.withValues(alpha: 0.06));
    canvas.drawRect(
        domain,
        Paint()
          ..color = foreground
          ..style = PaintingStyle.stroke);
    final axis = Paint()..color = foreground.withValues(alpha: 0.3);
    canvas.drawLine(transform.toScreen(Offset(-map.bound.toDouble(), 0)),
        transform.toScreen(Offset(map.bound.toDouble(), 0)), axis);
    canvas.drawLine(transform.toScreen(Offset(0, -map.bound.toDouble())),
        transform.toScreen(Offset(0, map.bound.toDouble())), axis);
    final visible = (Offset.zero & size).inflate(4);
    canvas.drawPoints(
        ui.PointMode.points,
        [
          for (final p in map.points)
            if (visible.contains(screen(p))) screen(p)
        ],
        Paint()
          ..color = foreground
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    final start = screen(root);
    final mark = Paint()
      ..color = highlight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
        Rect.fromCenter(center: start, width: 12, height: 12), mark);
    final selected = candidate;
    if (selected != null) canvas.drawCircle(screen(selected), 9, mark);
  }

  @override
  bool shouldRepaint(GaussianMoatPainter old) =>
      old.map != map ||
      old.view != view ||
      old.root != root ||
      old.candidate != candidate ||
      old.foreground != foreground ||
      old.background != background ||
      old.highlight != highlight;
}

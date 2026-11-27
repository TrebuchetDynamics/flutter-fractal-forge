import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractals/langton_ant_frame.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// One worker at a time. Slider drags can request many settings; only the
/// newest request after the active one needs a new walk.
class LangtonAntView extends StatefulWidget {
  const LangtonAntView(
      {super.key,
      required this.boundaryKey,
      required this.rule,
      required this.steps,
      required this.colorScheme,
      required this.view});

  final GlobalKey? boundaryKey;
  final String rule;
  final int steps, colorScheme;
  final FractalViewState view;

  @override
  State<LangtonAntView> createState() => _LangtonAntViewState();
}

class _LangtonAntViewState extends State<LangtonAntView> {
  LangtonAntPainter? _painter;
  bool _computing = false;

  (String, int) get _request => (widget.rule, widget.steps);

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant LangtonAntView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule || oldWidget.steps != widget.steps) {
      _prepare();
    }
  }

  Future<void> _prepare() async {
    if (_computing) return;
    final showing = _painter?.frame;
    if ((showing?.rule, showing?.requestedSteps) == _request) return;
    _computing = true;
    while (mounted) {
      final (rule, steps) = _request;
      final frame = await LangtonAntFrame.prepare(rule, steps);
      if (!mounted) return;
      if ((rule, steps) != _request) {
        if ((showing?.rule, showing?.requestedSteps) == _request) {
          setState(() => _computing = false);
          return;
        }
        continue;
      }
      setState(() {
        _painter = LangtonAntPainter(frame, widget.view, widget.colorScheme);
        _computing = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final painter = _painter;
    return Stack(fit: StackFit.expand, children: [
      if (painter != null)
        RepaintBoundary(
          key: widget.boundaryKey,
          child: CustomPaint(
            painter: painter.withStyle(widget.view, widget.colorScheme),
          ),
        )
      else
        const ColoredBox(color: Color(0xff090b12)),
      if (_computing || painter?.frame.stoppedAtBoundary == true)
        Align(
          alignment: Alignment.center,
          child: IgnorePointer(
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_computing
                      ? l10n.langtonAntComputing
                      : l10n.langtonAntBoundary(painter!.frame.completedSteps)),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

/// The boundary captures this same painter, transform and palette for PNG.
class LangtonAntPainter extends CustomPainter {
  LangtonAntPainter(this.frame, this.view, this.colorScheme)
      : _points = _groupPoints(frame),
        _colors = _palette(frame.rule.length, colorScheme);

  LangtonAntPainter._(
      this.frame, this.view, this.colorScheme, this._points, this._colors);

  final LangtonAntFrame frame;
  final FractalViewState view;
  final int colorScheme;
  final List<Float32List> _points;
  final List<Color> _colors;

  LangtonAntPainter withStyle(FractalViewState view, int scheme) =>
      LangtonAntPainter._(
          frame,
          view,
          scheme,
          _points,
          colorScheme == scheme
              ? _colors
              : _palette(frame.rule.length, scheme));

  static List<Float32List> _groupPoints(LangtonAntFrame frame) {
    final points = List.generate(frame.rule.length, (_) => <double>[]);
    for (final cell in frame.cells.entries) {
      points[cell.value]
        ..add(LangtonAntFrame.cellX(cell.key).toDouble())
        ..add(-LangtonAntFrame.cellY(cell.key).toDouble());
    }
    return points.map(Float32List.fromList).toList();
  }

  static List<Color> _palette(int length, int scheme) {
    List<FractalColorStop> stops;
    try {
      stops = PaletteService.instance.paletteAtIndex(scheme).stops;
    } on StateError {
      stops = fallbackFractalPaletteStops;
    }
    final gradient = normalizePaletteStops(stops);
    return List.generate(length, (i) {
      final t = i / (length - 1);
      final right = gradient.firstWhere((stop) => stop.position >= t);
      final left = gradient.lastWhere((stop) => stop.position <= t);
      final distance = right.position - left.position;
      return Color.lerp(left.color, right.color,
              distance == 0 ? 0 : (t - left.position) / distance)!
          .withValues(alpha: 1);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final viewport = Offset.zero & size;
    canvas.drawRect(viewport, Paint()..color = _colors.first);
    final shortest = size.shortestSide;
    if (shortest <= 0) return;
    final extent =
        math.max(frame.maxX - frame.minX + 1, frame.maxY - frame.minY + 1);
    final worldPixels = shortest * view.zoom;
    final cellPixels = 0.86 * worldPixels / extent;
    final fitCenter =
        Offset((frame.minX + frame.maxX) / 2, -(frame.minY + frame.maxY) / 2);
    final origin = viewport.center -
        Offset(view.pan.x, view.pan.y) * worldPixels -
        fitCenter * cellPixels;
    canvas.save();
    canvas.clipRect(viewport);
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(cellPixels);
    final paint = Paint()
      ..strokeWidth = 1
      ..isAntiAlias = false;
    for (var color = 1; color < _points.length; color++) {
      if (_points[color].isEmpty) continue;
      canvas.drawRawPoints(
          PointMode.points, _points[color], paint..color = _colors[color]);
    }
    canvas.restore();

    final ant =
        origin + Offset(frame.x.toDouble(), -frame.y.toDouble()) * cellPixels;
    final radius = (cellPixels * 0.4).clamp(3.0, 8.0);
    canvas.drawCircle(ant, radius + 1, Paint()..color = Colors.black);
    canvas.drawCircle(ant, radius, Paint()..color = Colors.white);
    canvas.drawCircle(ant, radius / 2, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant LangtonAntPainter oldDelegate) =>
      oldDelegate.frame != frame ||
      oldDelegate.view != view ||
      oldDelegate.colorScheme != colorScheme;
}

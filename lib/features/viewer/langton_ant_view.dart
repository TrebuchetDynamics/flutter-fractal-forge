import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractals/langton_ant_frame.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// One worker at a time. Slider drags can request many settings; only the
/// newest request after the active one needs a new walk.
class LangtonAntView extends StatefulWidget {
  const LangtonAntView(
      {super.key, required this.boundaryKey, required this.controller});

  final GlobalKey? boundaryKey;
  final FractalController controller;

  @override
  State<LangtonAntView> createState() => _LangtonAntViewState();
}

class _LangtonAntViewState extends State<LangtonAntView> {
  static const _growthInterval = Duration(milliseconds: 50);
  LangtonAntPainter? _painter;
  LangtonAntWalk? _walk;
  Timer? _growthTimer;
  bool _advancing = false;
  bool _computing = false;

  FractalController get _controller => widget.controller;
  (String, int)? get _request => _controller.module.id == 'langton_ant'
      ? (
          _controller.params['rule'] as String,
          _controller.params['steps'] as int
        )
      : null;
  (String, int)? get _showing {
    final frame = _painter?.frame;
    return frame == null ? null : (frame.rule, frame.requestedSteps);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onParametersChanged);
    _prepare();
  }

  void _onParametersChanged() {
    if (_request == _showing) return;
    _stopGrowth();
    _walk = null;
    if (_request != null && !_computing) {
      unawaited(_prepare());
      setState(() {});
    }
  }

  Future<void> _prepare() async {
    _computing = true;
    while (mounted) {
      final request = _request;
      if (request == null) return;
      final (rule, steps) = request;
      final frame = await LangtonAntFrame.prepare(rule, steps);
      if (!mounted || _request == null) return;
      final painter = request == _request ? await _preparePainter(frame) : null;
      if (!mounted) return;
      if (request != _request && _request != _showing) continue;
      setState(() {
        if (request == _request && painter != null) _painter = painter;
        _computing = false;
      });
      return;
    }
  }

  Future<LangtonAntPainter> _preparePainter(LangtonAntFrame frame) =>
      LangtonAntPainter.prepare(
          frame, _controller.view, _controller.params['colorScheme'] as int);

  bool get _reducedMotion =>
      MediaQuery.disableAnimationsOf(context) ||
      context.read<AccessibilityService?>()?.reducedMotionEnabled == true;

  void _toggleGrowth() {
    if (_growthTimer != null) {
      setState(_stopGrowth);
      return;
    }
    if (_reducedMotion || _computing) return;
    setState(
        () => _growthTimer = Timer.periodic(_growthInterval, _advanceGrowth));
  }

  void _stopGrowth() {
    _growthTimer?.cancel();
    _growthTimer = null;
    // If a batch was in flight, resume from the last displayed frame instead.
    if (_advancing) _walk = null;
  }

  Future<void> _advanceGrowth(Timer timer) async {
    if (_reducedMotion) {
      setState(_stopGrowth);
      return;
    }
    if (_advancing) return;
    final current = _painter!.frame;
    _advancing = true;
    try {
      final walk = _walk ?? await LangtonAntWalk.resume(current);
      if (timer != _growthTimer) return;
      // About 12 s to the RL highway from zero, with a bounded batch even
      // when starting from a high slider value. Never catch up missed ticks.
      final count = math.min(4096, 24 + current.completedSteps ~/ 180);
      walk.advanceTo(
          math.min(langtonAntMaxSteps, current.completedSteps + count));
      final frame = await walk.snapshot();
      if (timer != _growthTimer) return;
      final painter = await _preparePainter(frame);
      if (timer != _growthTimer) return;
      if (_reducedMotion) {
        setState(_stopGrowth);
        return;
      }
      setState(() {
        _painter = painter;
        if (frame.stoppedAtBoundary ||
            frame.completedSteps == langtonAntMaxSteps) {
          _stopGrowth();
        }
        _walk = walk;
      });
      _controller.updateParam('steps', frame.completedSteps);
    } finally {
      _advancing = false;
    }
  }

  @override
  void dispose() {
    _stopGrowth();
    _controller.removeListener(_onParametersChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reducedMotion =
        context.watch<AccessibilityService?>()?.reducedMotionEnabled == true ||
            MediaQuery.disableAnimationsOf(context);
    if (reducedMotion) _stopGrowth();
    final painter = _painter;
    final frame = painter?.frame;
    final playing = _growthTimer != null;
    return Stack(fit: StackFit.expand, children: [
      if (painter != null)
        RepaintBoundary(
          // The retained grid is visible during a walk, but must not be
          // exported as the newly requested rule/step count.
          key: _showing == _request ? widget.boundaryKey : null,
          child: CustomPaint(
            painter: painter.withStyle(
                _controller.view, _controller.params['colorScheme'] as int),
          ),
        )
      else
        const ColoredBox(color: Color(0xff090b12)),
      if (frame != null)
        Positioned(
          top: MediaQuery.paddingOf(context).top + 64,
          left: 12,
          right: 12,
          child: Center(
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    Text(l10n.langtonAntCurrentStep(frame.completedSteps)),
                    if (!reducedMotion)
                      FilledButton(
                        onPressed: _computing ||
                                frame.stoppedAtBoundary ||
                                frame.completedSteps == langtonAntMaxSteps
                            ? null
                            : _toggleGrowth,
                        child:
                            Text(playing ? l10n.actionPause : l10n.actionPlay),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

  static Future<LangtonAntPainter> prepare(
      LangtonAntFrame frame, FractalViewState view, int scheme) async {
    final points = List.generate(frame.rule.length, (_) => <double>[]);
    var count = 0;
    for (final cell in frame.cells.entries) {
      points[cell.value]
        ..add(LangtonAntFrame.cellX(cell.key).toDouble())
        ..add(-LangtonAntFrame.cellY(cell.key).toDouble());
      if (++count % 8192 == 0) await Future<void>.delayed(Duration.zero);
    }
    return LangtonAntPainter._(
        frame,
        view,
        scheme,
        points.map(Float32List.fromList).toList(),
        _palette(frame.rule.length, scheme));
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

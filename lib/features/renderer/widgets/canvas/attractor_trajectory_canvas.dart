import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/attractor_trajectory.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';

final AttractorTrajectoryCache _trajectoryCache = AttractorTrajectoryCache();

/// Stateful finite-orbit surface; integration runs in cancellable chunks and is
/// cached independently of pan, zoom, palette and output size.
class AttractorTrajectoryCanvas extends StatefulWidget {
  final OrbitTrajectorySettings settings;
  final FractalViewState view;
  final int colorScheme;
  final bool transparentBackground;
  final bool glowEnabled;
  final double glowSigma;
  final double glowIntensity;
  final void Function(Duration elapsed, bool cacheHit)? onGenerationComplete;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final double kaleidoscopeRotation;
  final int kaleidoscopeMirrorMode;

  const AttractorTrajectoryCanvas({
    super.key,
    required this.settings,
    required this.view,
    required this.colorScheme,
    required this.transparentBackground,
    this.glowEnabled = false,
    this.glowSigma = 1,
    this.glowIntensity = 0.35,
    this.onGenerationComplete,
    this.kaleidoscopeEnabled = false,
    this.kaleidoscopeSectors = 8,
    this.kaleidoscopeMirror = true,
    this.kaleidoscopeRotation = 0,
    this.kaleidoscopeMirrorMode = 0,
  });

  @override
  State<AttractorTrajectoryCanvas> createState() =>
      _AttractorTrajectoryCanvasState();
}

class _AttractorTrajectoryCanvasState extends State<AttractorTrajectoryCanvas> {
  AttractorTrajectory? _trajectory;
  AttractorTrajectoryCancellation? _cancellation;
  int _generation = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _generate(widget.settings);
  }

  @override
  void didUpdateWidget(covariant AttractorTrajectoryCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _generate(widget.settings);
    }
  }

  void _generate(OrbitTrajectorySettings settings) {
    _cancellation?.cancel();
    final cancellation = AttractorTrajectoryCancellation();
    _cancellation = cancellation;
    final generation = ++_generation;
    final cached = _trajectoryCache[settings];
    if (cached != null) {
      widget.onGenerationComplete?.call(Duration.zero, true);
      setState(() {
        _trajectory = cached;
        _error = null;
      });
      return;
    }
    setState(() {
      _trajectory = null;
      _error = null;
    });
    final stopwatch = Stopwatch()..start();
    _trajectoryCache
        .getOrGenerate(settings, cancellation: cancellation)
        .then((trajectory) {
      stopwatch.stop();
      if (!mounted || generation != _generation || trajectory == null) return;
      widget.onGenerationComplete?.call(stopwatch.elapsed, false);
      setState(() => _trajectory = trajectory);
    }).catchError((Object error) {
      if (!mounted || generation != _generation) return;
      setState(() => _error = error);
    });
  }

  @override
  void dispose() {
    _generation++;
    _cancellation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trajectory = _trajectory;
    if (_error != null) {
      return Center(
        child: Text(
          'Trajectory rendering failed: $_error',
          key: const Key('attractorTrajectoryError'),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (trajectory == null) {
      return const ColoredBox(
        color: Color(0xff05070e),
        child: Center(
          child: CircularProgressIndicator(
            key: Key('attractorTrajectoryGenerating'),
          ),
        ),
      );
    }
    return CustomPaint(
      key: const Key('attractorTrajectoryRendered'),
      painter: AttractorTrajectoryPainter(
        trajectory: trajectory,
        view: widget.view,
        colorScheme: widget.colorScheme,
        transparentBackground: widget.transparentBackground,
        glowEnabled: widget.glowEnabled,
        glowSigma: widget.glowSigma,
        glowIntensity: widget.glowIntensity,
        kaleidoscopeEnabled: widget.kaleidoscopeEnabled,
        kaleidoscopeSectors: widget.kaleidoscopeSectors,
        kaleidoscopeMirror: widget.kaleidoscopeMirror,
        kaleidoscopeRotation: widget.kaleidoscopeRotation,
        kaleidoscopeMirrorMode: widget.kaleidoscopeMirrorMode,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class AttractorTrajectoryPainter extends CustomPainter {
  final AttractorTrajectory trajectory;
  final FractalViewState view;
  final int colorScheme;
  final bool transparentBackground;
  final bool glowEnabled;
  final double glowSigma;
  final double glowIntensity;
  final bool kaleidoscopeEnabled;
  final int kaleidoscopeSectors;
  final bool kaleidoscopeMirror;
  final double kaleidoscopeRotation;
  final int kaleidoscopeMirrorMode;

  AttractorTrajectoryPainter({
    required this.trajectory,
    required this.view,
    required this.colorScheme,
    required this.transparentBackground,
    required this.glowEnabled,
    required this.glowSigma,
    required this.glowIntensity,
    required this.kaleidoscopeEnabled,
    required this.kaleidoscopeSectors,
    required this.kaleidoscopeMirror,
    required this.kaleidoscopeRotation,
    required this.kaleidoscopeMirrorMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (!transparentBackground)
      canvas.drawColor(const Color(0xff05070e), BlendMode.src);
    final geometry = _TrajectoryPathCache.instance.pathsFor(
      trajectory,
      view,
      size,
    );
    void drawPaths() {
      for (var i = 0; i < geometry.length; i++) {
        final path = geometry[i];
        final color = _paletteColor(i, geometry.length, colorScheme);
        if (glowEnabled && glowIntensity > 0) {
          canvas.drawPath(
            path,
            Paint()
              ..color =
                  color.withValues(alpha: glowIntensity.clamp(0.0, 1.0) * 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2 + glowSigma.clamp(0.1, 5.0) * 1.5
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                glowSigma.clamp(0.1, 5.0) * 1.5,
              ),
          );
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    if (!kaleidoscopeEnabled) {
      drawPaths();
      return;
    }
    final sectors = kaleidoscopeSectors.clamp(4, 16);
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.sqrt(size.width * size.width + size.height * size.height) * 2;
    final sectorAngle = 2 * math.pi / sectors;
    final edges = List<Offset>.generate(sectors, (i) {
      final angle = kaleidoscopeRotation + (i - 0.5) * sectorAngle;
      return center + Offset(math.cos(angle), math.sin(angle)) * radius;
    });
    final wedge = Path();
    for (var i = 0; i < sectors; i++) {
      canvas.save();
      wedge
        ..reset()
        ..moveTo(center.dx, center.dy)
        ..lineTo(edges[i].dx, edges[i].dy)
        ..lineTo(edges[(i + 1) % sectors].dx, edges[(i + 1) % sectors].dy)
        ..close();
      canvas.clipPath(wedge, doAntiAlias: false);
      final scale = FractalCanvas.kaleidoscopeSectorScale(
        mirror: kaleidoscopeMirror,
        mode: kaleidoscopeMirrorMode,
        sector: i,
      );
      canvas.translate(center.dx, center.dy);
      canvas.rotate(kaleidoscopeRotation + i * sectorAngle);
      canvas.scale(scale.dx, scale.dy);
      canvas.translate(-center.dx, -center.dy);
      drawPaths();
      canvas.restore();
    }
  }

  static Color _paletteColor(int index, int count, int scheme) {
    final t = index / math.max(1, count);
    if (scheme == 3) {
      final gray = (0.5 + 0.5 * math.cos(2 * math.pi * t)) * 255;
      return Color.fromARGB(255, gray.round(), gray.round(), gray.round());
    }

    late final List<double> a;
    late final List<double> b;
    late final List<double> c;
    late final List<double> d;
    switch (scheme) {
      case 1:
        a = const [0.5, 0.5, 0.5];
        b = const [0.5, 0.5, 0.5];
        c = const [1, 1, 1];
        d = const [0.5, 0.3, 0];
        break;
      case 2:
        a = const [0.5, 0.5, 0.5];
        b = const [0.5, 0.5, 0.5];
        c = const [1, 0.7, 0.4];
        d = const [0, 0.15, 0.2];
        break;
      default:
        a = const [0.5, 0.5, 0.5];
        b = const [0.5, 0.5, 0.5];
        c = const [1, 1, 1];
        d = const [0, 0.33, 0.67];
    }
    final components = List<int>.generate(3, (channel) {
      final linear = (a[channel] +
              b[channel] *
                  math.cos(2 * math.pi * (c[channel] * t + d[channel])))
          .clamp(0.0, 1.0);
      final double srgb = linear <= 0.0031308
          ? linear * 12.92
          : 1.055 * math.pow(linear, 1 / 2.4) - 0.055;
      return (srgb * 255).round().clamp(0, 255).toInt();
    });
    return Color.fromARGB(255, components[0], components[1], components[2]);
  }

  @override
  bool shouldRepaint(covariant AttractorTrajectoryPainter oldDelegate) {
    return oldDelegate.trajectory.settings != trajectory.settings ||
        oldDelegate.view.zoom != view.zoom ||
        oldDelegate.view.pan.x != view.pan.x ||
        oldDelegate.view.pan.y != view.pan.y ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.transparentBackground != transparentBackground ||
        oldDelegate.glowEnabled != glowEnabled ||
        oldDelegate.glowSigma != glowSigma ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.kaleidoscopeEnabled != kaleidoscopeEnabled ||
        oldDelegate.kaleidoscopeSectors != kaleidoscopeSectors ||
        oldDelegate.kaleidoscopeMirror != kaleidoscopeMirror ||
        oldDelegate.kaleidoscopeRotation != kaleidoscopeRotation ||
        oldDelegate.kaleidoscopeMirrorMode != kaleidoscopeMirrorMode;
  }
}

class _TrajectoryPathCache {
  static final instance = _TrajectoryPathCache._();
  static const int _maximumEntries = 8;
  final LinkedHashMap<String, List<Path>> _paths = LinkedHashMap();

  _TrajectoryPathCache._();

  List<Path> pathsFor(
    AttractorTrajectory trajectory,
    FractalViewState view,
    Size size,
  ) {
    final pan = view.pan;
    final key = '${trajectory.settings.cacheKey}:${size.width}:${size.height}:'
        '${pan.x}:${pan.y}:${view.zoom}';
    final cached = _paths.remove(key);
    if (cached != null) {
      _paths[key] = cached;
      return cached;
    }

    final bounds = trajectory.bounds;
    final rangeX = math.max(1e-12, bounds.maxX - bounds.minX);
    final rangeY = math.max(1e-12, bounds.maxY - bounds.minY);
    final scale =
        math.min(size.width * 0.84 / rangeX, size.height * 0.84 / rangeY) *
            view.zoom;
    final centerX = (bounds.minX + bounds.maxX) / 2;
    final centerY = (bounds.minY + bounds.maxY) / 2;
    Offset screenPoint(OrbitPoint point) {
      final projected = AttractorTrajectoryModel.project(
        point,
        trajectory.settings.projection,
      );
      return Offset(
        size.width / 2 + (projected.x - centerX + pan.x) * scale,
        size.height / 2 - (projected.y - centerY + pan.y) * scale,
      );
    }

    const paletteBands = 64;
    final paths = List<Path>.generate(paletteBands, (_) => Path());
    final points = trajectory.points;
    final segmentCount = points.length - 1;
    for (var i = 0; i < segmentCount; i++) {
      final band =
          (i * paletteBands ~/ segmentCount).clamp(0, paletteBands - 1);
      final path = paths[band]
        ..moveTo(screenPoint(points[i]).dx, screenPoint(points[i]).dy);
      final end = screenPoint(points[i + 1]);
      path.lineTo(end.dx, end.dy);
    }
    final result = List<Path>.unmodifiable(paths);
    _paths[key] = result;
    while (_paths.length > _maximumEntries) {
      _paths.remove(_paths.keys.first);
    }
    return result;
  }
}

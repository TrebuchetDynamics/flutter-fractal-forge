import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:vector_math/vector_math.dart';

/// Auto-explore configuration.
class AutoExploreConfig {
  /// Sample grid size (NxN) around current view.
  final int grid;

  /// Quick iteration budget for interest scoring.
  final int quickIterations;

  /// Minimum normalized boundary score (0..1) to accept a candidate.
  final double minScore;

  /// How far from the current pan we sample (in "plane units"), scaled by 1/zoom.
  final double radius;

  /// Minimum and maximum zoom targets.
  final double minZoom;
  final double maxZoom;

  /// Duration for a travel animation.
  final Duration travelDuration;

  /// Delay between travels.
  final Duration dwellDuration;

  const AutoExploreConfig({
    this.grid = 9,
    this.quickIterations = 64,
    this.minScore = 0.28,
    this.radius = 1.4,
    this.minZoom = 0.2,
    this.maxZoom = 500.0,
    this.travelDuration = const Duration(milliseconds: 2200),
    this.dwellDuration = const Duration(milliseconds: 900),
  });
}

class AutoExploreTarget {
  final Vector2 pan;
  final double zoom;
  final double score;

  const AutoExploreTarget({required this.pan, required this.zoom, required this.score});
}

/// Auto-explore mode: automatically pans/zooms to interesting boundary regions.
///
/// For 2D fractals it evaluates iteration variance in a neighborhood (a proxy
/// for boundary complexity). It then animates the view toward a high-scoring
/// candidate and slightly increases zoom.
class AutoExploreService extends ChangeNotifier {
  final FractalController controller;
  final AutoExploreConfig config;

  bool _isExploring = false;
  bool _isPaused = false;
  double _speed = 1.0;

  Timer? _timer;
  Timer? _anim;

  // Keep a short history to avoid revisits.
  final List<Vector2> _visited = <Vector2>[];
  static const int _visitedMax = 18;

  AutoExploreService({required this.controller, this.config = const AutoExploreConfig()});

  bool get isExploring => _isExploring;
  bool get isPaused => _isPaused;

  double get speed => _speed;
  set speed(double v) {
    _speed = v.clamp(0.25, 4.0);
    notifyListeners();
  }

  void start() {
    if (_isExploring && !_isPaused) return;
    _isExploring = true;
    _isPaused = false;
    _scheduleNext();
    notifyListeners();
  }

  void pause() {
    if (!_isExploring) return;
    _isPaused = true;
    _timer?.cancel();
    _anim?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!_isExploring) {
      start();
      return;
    }
    _isPaused = false;
    _scheduleNext();
    notifyListeners();
  }

  void toggle() {
    if (!_isExploring) return start();
    if (_isPaused) return resume();
    return pause();
  }

  void stop() {
    _isExploring = false;
    _isPaused = false;
    _timer?.cancel();
    _anim?.cancel();
    _visited.clear();
    notifyListeners();
  }

  void _scheduleNext() {
    _timer?.cancel();
    final dwell = Duration(milliseconds: (config.dwellDuration.inMilliseconds / _speed).round());
    _timer = Timer(dwell, () async {
      if (!_isExploring || _isPaused) return;
      final target = await compute(_findTargetIsolate, _IsolateParams(
        moduleId: controller.module.id,
        params: controller.params,
        pan: controller.view.pan,
        zoom: controller.view.zoom,
        grid: config.grid,
        radius: config.radius,
        quickIterations: config.quickIterations,
        minScore: config.minScore,
        visited: List<Vector2>.from(_visited),
        seed: DateTime.now().microsecondsSinceEpoch,
      ));

      if (!_isExploring || _isPaused) return;

      if (target == null) {
        // fallback gentle drift + zoom out a bit
        final angle = Random().nextDouble() * 2 * pi;
        final drift = (config.radius / controller.view.zoom) * 0.7;
        await _animateTo(
          Vector2(controller.view.pan.x + cos(angle) * drift, controller.view.pan.y + sin(angle) * drift),
          (controller.view.zoom * 0.85).clamp(config.minZoom, config.maxZoom),
        );
        _scheduleNext();
        return;
      }

      _visited.add(target.pan);
      if (_visited.length > _visitedMax) _visited.removeAt(0);

      await _animateTo(target.pan, target.zoom.clamp(config.minZoom, config.maxZoom));
      controller.recordInterestingSpot();
      _scheduleNext();
    });
  }

  Future<void> _animateTo(Vector2 pan, double zoom) async {
    _anim?.cancel();

    final startPan = controller.view.pan;
    final startZoom = controller.view.zoom;

    final duration = Duration(milliseconds: (config.travelDuration.inMilliseconds / _speed).round());
    const frame = Duration(milliseconds: 16);
    final total = max(1, (duration.inMilliseconds / frame.inMilliseconds).round());
    var step = 0;

    final completer = Completer<void>();
    _anim = Timer.periodic(frame, (t) {
      if (!_isExploring || _isPaused) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }

      step++;
      final raw = (step / total).clamp(0.0, 1.0);
      final eased = raw < 0.5 ? 4 * raw * raw * raw : 1 - pow(-2 * raw + 2, 3) / 2;

      controller.updatePan(Vector2(
        _lerp(startPan.x, pan.x, eased),
        _lerp(startPan.y, pan.y, eased),
      ));
      controller.updateZoom(_lerp(startZoom, zoom, eased));

      if (raw >= 1.0) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

class _IsolateParams {
  final String moduleId;
  final Map<String, Object> params;
  final Vector2 pan;
  final double zoom;
  final int grid;
  final double radius;
  final int quickIterations;
  final double minScore;
  final List<Vector2> visited;
  final int seed;

  const _IsolateParams({
    required this.moduleId,
    required this.params,
    required this.pan,
    required this.zoom,
    required this.grid,
    required this.radius,
    required this.quickIterations,
    required this.minScore,
    required this.visited,
    required this.seed,
  });
}

AutoExploreTarget? _findTargetIsolate(_IsolateParams p) {
  final rnd = Random(p.seed);

  final searchR = (p.radius / max(0.0001, p.zoom));
  final grid = max(3, p.grid);

  AutoExploreTarget? best;

  for (var gy = 0; gy < grid; gy++) {
    for (var gx = 0; gx < grid; gx++) {
      final nx = (gx / (grid - 1)) * 2 - 1;
      final ny = (gy / (grid - 1)) * 2 - 1;

      final jitterX = (rnd.nextDouble() * 0.18 - 0.09);
      final jitterY = (rnd.nextDouble() * 0.18 - 0.09);

      final candidate = Vector2(
        p.pan.x + (nx + jitterX) * searchR,
        p.pan.y + (ny + jitterY) * searchR,
      );

      if (_nearVisited(candidate, p.visited, searchR * 0.35)) continue;

      final score = _boundaryScore(candidate, p.moduleId, p.params, p.quickIterations);
      if (score < p.minScore) continue;

      final zoomTarget = p.zoom * (1.25 + 1.8 * score);
      final t = AutoExploreTarget(pan: candidate, zoom: zoomTarget, score: score);

      if (best == null || t.score > best.score) best = t;
    }
  }

  return best;
}

bool _nearVisited(Vector2 pos, List<Vector2> visited, double minDist) {
  final md2 = minDist * minDist;
  for (final v in visited) {
    final dx = pos.x - v.x;
    final dy = pos.y - v.y;
    if (dx * dx + dy * dy < md2) return true;
  }
  return false;
}

// Score by iteration variance over a tiny neighborhood (high variance => boundary).
double _boundaryScore(Vector2 pos, String moduleId, Map<String, Object> params, int iters) {
  const n = 5;
  const eps = 0.008;
  final values = <int>[];

  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      final ox = (x - (n - 1) / 2) * eps;
      final oy = (y - (n - 1) / 2) * eps;
      values.add(_iterations(Vector2(pos.x + ox, pos.y + oy), moduleId, params, iters));
    }
  }

  final mean = values.reduce((a, b) => a + b) / values.length;
  var varSum = 0.0;
  for (final v in values) {
    final d = v - mean;
    varSum += d * d;
  }
  final variance = varSum / values.length;
  final normalized = (sqrt(variance) / max(1, iters)).clamp(0.0, 1.0);

  // Encourage points near-but-not-inside: mean between 0.25..0.95 of max.
  final ratio = (mean / max(1, iters)).clamp(0.0, 1.0);
  final boost = (ratio > 0.25 && ratio < 0.95) ? 0.18 : 0.0;

  return (normalized + boost).clamp(0.0, 1.0);
}

int _iterations(Vector2 pos, String moduleId, Map<String, Object> params, int maxIter) {
  switch (moduleId) {
    case 'julia':
      final cr = _getDouble(params, 'juliaCReal', -0.8);
      final ci = _getDouble(params, 'juliaCImag', 0.156);
      return _julia(pos.x, pos.y, cr, ci, maxIter);
    case 'burning_ship':
      return _burningShip(pos.x, pos.y, maxIter);
    case 'mandelbrot':
    default:
      return _mandelbrot(pos.x, pos.y, maxIter);
  }
}

double _getDouble(Map<String, Object> params, String key, double fallback) {
  final v = params[key];
  if (v is int) return v.toDouble();
  if (v is double) return v;
  return fallback;
}

int _mandelbrot(double cr, double ci, int maxIter) {
  var zr = 0.0;
  var zi = 0.0;
  var i = 0;
  while (zr * zr + zi * zi <= 4.0 && i < maxIter) {
    final tr = zr * zr - zi * zi + cr;
    zi = 2.0 * zr * zi + ci;
    zr = tr;
    i++;
  }
  return i;
}

int _julia(double zr, double zi, double cr, double ci, int maxIter) {
  var i = 0;
  while (zr * zr + zi * zi <= 4.0 && i < maxIter) {
    final tr = zr * zr - zi * zi + cr;
    zi = 2.0 * zr * zi + ci;
    zr = tr;
    i++;
  }
  return i;
}

int _burningShip(double cr, double ci, int maxIter) {
  var zr = 0.0;
  var zi = 0.0;
  var i = 0;
  while (zr * zr + zi * zi <= 4.0 && i < maxIter) {
    final tr = zr * zr - zi * zi + cr;
    zi = (2.0 * zr * zi).abs() + ci;
    zr = tr.abs();
    i++;
  }
  return i;
}

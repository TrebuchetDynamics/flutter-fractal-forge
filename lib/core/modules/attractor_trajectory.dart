import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/attractor_trajectory_settings.dart';

export 'package:flutter_fractals/core/models/attractor_trajectory_settings.dart';

@immutable
class OrbitBounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const OrbitBounds(this.minX, this.maxX, this.minY, this.maxY);

  bool get isFinite =>
      minX.isFinite && maxX.isFinite && minY.isFinite && maxY.isFinite;
}

@immutable
class AttractorTrajectory {
  final OrbitTrajectorySettings settings;
  final List<OrbitPoint> points;
  final OrbitBounds bounds;

  AttractorTrajectory._(this.settings, List<OrbitPoint> points, this.bounds)
      : points = List<OrbitPoint>.unmodifiable(points);
}

class AttractorTrajectoryCancellation {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() => _isCancelled = true;
}

/// Independent fixed-step RK4 model for the three reviewed vector fields.
class AttractorTrajectoryModel {
  const AttractorTrajectoryModel._();

  static OrbitPoint integrate({
    required AttractorSystem system,
    required OrbitPoint initial,
    required double dt,
    required int steps,
  }) {
    if (!initial.isFinite || !dt.isFinite || dt <= 0 || steps < 0) {
      throw ArgumentError('Integration inputs must be finite and bounded.');
    }
    var state = initial;
    for (var i = 0; i < steps; i++) {
      state = _rk4(system, state, dt);
      if (!state.isFinite) {
        throw StateError(
            'Attractor integration diverged to a non-finite state.');
      }
    }
    return state;
  }

  static ProjectedOrbitPoint project(
    OrbitPoint point,
    OrbitProjection projection,
  ) {
    return switch (projection) {
      OrbitProjection.xz => ProjectedOrbitPoint(point.x, point.z),
      OrbitProjection.thomasOblique => ProjectedOrbitPoint(
          (point.x - point.y) / math.sqrt(2),
          (point.x + point.y - 2 * point.z) / math.sqrt(6),
        ),
    };
  }

  static AttractorTrajectory generate(OrbitTrajectorySettings settings) {
    var state = settings.seed;
    for (var i = 0; i < settings.burnInSteps; i++) {
      state = _checkedStep(settings.system, state, settings.stepSize);
    }
    final points = <OrbitPoint>[];
    for (var i = 0; i < settings.retainedSteps; i++) {
      state = _checkedStep(settings.system, state, settings.stepSize);
      points.add(state);
    }
    return _trajectory(settings, points);
  }

  static Future<AttractorTrajectory?> generateAsync(
    OrbitTrajectorySettings settings, {
    required AttractorTrajectoryCancellation cancellation,
    int stepsPerChunk = 256,
  }) async {
    if (stepsPerChunk <= 0) {
      throw ArgumentError.value(stepsPerChunk, 'stepsPerChunk');
    }
    var state = settings.seed;
    var stepsInChunk = 0;
    final totalSteps = settings.burnInSteps + settings.retainedSteps;
    final points = <OrbitPoint>[];
    for (var step = 0; step < totalSteps; step++) {
      if (cancellation.isCancelled) return null;
      state = _checkedStep(settings.system, state, settings.stepSize);
      if (step >= settings.burnInSteps) points.add(state);
      if (++stepsInChunk == stepsPerChunk) {
        stepsInChunk = 0;
        await Future<void>.delayed(Duration.zero);
      }
    }
    if (cancellation.isCancelled) return null;
    return _trajectory(settings, points);
  }

  static OrbitPoint _checkedStep(
      AttractorSystem system, OrbitPoint state, double dt) {
    final next = _rk4(system, state, dt);
    if (!next.isFinite ||
        next.x.abs() > 1e12 ||
        next.y.abs() > 1e12 ||
        next.z.abs() > 1e12) {
      throw StateError('Attractor trajectory left the finite safety bounds.');
    }
    return next;
  }

  static OrbitPoint _rk4(AttractorSystem system, OrbitPoint p, double dt) {
    final k1 = _derivative(system, p);
    final k2 = _derivative(system, p + k1 * (dt / 2));
    final k3 = _derivative(system, p + k2 * (dt / 2));
    final k4 = _derivative(system, p + k3 * dt);
    return p + (k1 + k2 * 2 + k3 * 2 + k4) * (dt / 6);
  }

  static OrbitPoint _derivative(AttractorSystem system, OrbitPoint p) {
    return switch (system) {
      AttractorSystem.thomas => OrbitPoint(
          math.sin(p.y) - 0.208186 * p.x,
          math.sin(p.z) - 0.208186 * p.y,
          math.sin(p.x) - 0.208186 * p.z,
        ),
      AttractorSystem.fourWing => OrbitPoint(
          0.2 * p.x + p.y * p.z,
          0.01 * p.x - 0.4 * p.y - p.x * p.z,
          -p.z - p.x * p.y + 0.6,
        ),
      AttractorSystem.lorenz2d => OrbitPoint(
          10 * (p.y - p.x),
          p.x * (28 - p.z) - p.y,
          p.x * p.y - (8 / 3) * p.z,
        ),
    };
  }

  static AttractorTrajectory _trajectory(
    OrbitTrajectorySettings settings,
    List<OrbitPoint> points,
  ) {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (final point in points) {
      final projected = project(point, settings.projection);
      minX = math.min(minX, projected.x);
      maxX = math.max(maxX, projected.x);
      minY = math.min(minY, projected.y);
      maxY = math.max(maxY, projected.y);
    }
    return AttractorTrajectory._(
      settings,
      points,
      OrbitBounds(minX, maxX, minY, maxY),
    );
  }
}

/// Small LRU cache; view and palette changes reuse the same orbit samples.
class AttractorTrajectoryCache {
  static const int maximumEntries = 3;
  final LinkedHashMap<String, AttractorTrajectory> _entries = LinkedHashMap();

  int get length => _entries.length;

  AttractorTrajectory? operator [](OrbitTrajectorySettings settings) {
    final key = settings.cacheKey;
    final value = _entries.remove(key);
    if (value != null) _entries[key] = value;
    return value;
  }

  Future<AttractorTrajectory?> getOrGenerate(
    OrbitTrajectorySettings settings, {
    required AttractorTrajectoryCancellation cancellation,
    int stepsPerChunk = 256,
  }) async {
    final cached = this[settings];
    if (cached != null) return cached;
    final trajectory = await AttractorTrajectoryModel.generateAsync(
      settings,
      cancellation: cancellation,
      stepsPerChunk: stepsPerChunk,
    );
    if (trajectory != null) store(trajectory);
    return trajectory;
  }

  void store(AttractorTrajectory trajectory) {
    final key = trajectory.settings.cacheKey;
    _entries.remove(key);
    _entries[key] = trajectory;
    while (_entries.length > maximumEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() => _entries.clear();
}

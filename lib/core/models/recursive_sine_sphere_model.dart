import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

enum RecursiveSineRayStatus { hit, tangent, miss, unresolved }

class RecursiveSineRayHit {
  const RecursiveSineRayHit(this.status, this.distance, this.residual);

  final RecursiveSineRayStatus status;
  final double distance;
  final double residual;
}

/// Independent double-precision reference for the finite cyclic level set.
class RecursiveSineSphereModel {
  RecursiveSineSphereModel({
    required this.depth,
    required this.strength,
    required this.radius,
    required this.phase,
  }) {
    if (depth < 0 || depth > maxDepth) {
      throw RangeError.range(depth, 0, maxDepth, 'depth');
    }
    if (!strength.isFinite || strength < 0 || strength > 1) {
      throw ArgumentError.value(strength, 'strength', 'must be in [0, 1]');
    }
    if (!radius.isFinite || radius < 0.25 || radius > 2) {
      throw ArgumentError.value(radius, 'radius', 'must be in [0.25, 2]');
    }
    if (!phase.isFinite) {
      throw ArgumentError.value(phase, 'phase', 'must be finite');
    }
  }

  static const maxDepth = 6;
  static const maxRaySteps = 512;
  static const residualTolerance = 2e-5;

  final int depth;
  final double strength;
  final double radius;
  final double phase;

  double get lipschitzBound => math.pow(1 + strength, depth).toDouble();

  double get enclosureRadius =>
      radius + math.sqrt(3) * strength * (2 * (1 - math.pow(0.5, depth)));

  Vector3 warp(Vector3 point) {
    _requireFinite(point, 'point');
    var q = point.clone();
    for (var n = 0; n < depth; n++) {
      final frequency = math.pow(2, n).toDouble();
      final old = q;
      q = Vector3(
        old.x + strength / frequency * math.sin(frequency * old.y + phase),
        old.y + strength / frequency * math.sin(frequency * old.z + phase),
        old.z + strength / frequency * math.sin(frequency * old.x + phase),
      );
    }
    return q;
  }

  double field(Vector3 point) {
    final value = warp(point).length - radius;
    if (!value.isFinite) throw ArgumentError('field evaluation is nonfinite');
    return value;
  }

  Vector3 normal(Vector3 point, {double epsilon = 0.001}) {
    _requireFinite(point, 'point');
    if (!epsilon.isFinite || epsilon <= 0 || epsilon > 0.1) {
      throw ArgumentError.value(epsilon, 'epsilon', 'must be in (0, 0.1]');
    }
    final dx = Vector3(epsilon, 0, 0);
    final dy = Vector3(0, epsilon, 0);
    final dz = Vector3(0, 0, epsilon);
    final gradient = Vector3(
      field(point + dx) - field(point - dx),
      field(point + dy) - field(point - dy),
      field(point + dz) - field(point - dz),
    );
    final length = gradient.length;
    return length.isFinite && length > 1e-12
        ? gradient / length
        : Vector3(0, 0, 1);
  }

  RecursiveSineRayHit intersectRay({
    required Vector3 origin,
    required Vector3 direction,
    int maxSteps = maxRaySteps,
  }) {
    _requireFinite(origin, 'origin');
    _requireFinite(direction, 'direction');
    if (direction.length2 <= 0 || !direction.length2.isFinite) {
      throw ArgumentError.value(direction, 'direction', 'must be nonzero');
    }
    if (maxSteps < 1 || maxSteps > maxRaySteps) {
      throw RangeError.range(maxSteps, 1, maxRaySteps, 'maxSteps');
    }
    final ray = direction.normalized();
    if (depth == 0 || strength == 0) return _sphereHit(origin, ray);

    final interval = _sphereInterval(origin, ray, enclosureRadius);
    if (interval == null) return _miss;
    var t = math.max(0.0, interval.$1).toDouble();
    final exit = interval.$2;
    var value = field(origin + ray * t);
    if (value.abs() <= residualTolerance) {
      return _directionalSlope(origin, ray, t) < 2e-5
          ? _tangent(t, value)
          : _hit(t, value);
    }
    for (var i = 0; i < maxSteps && t < exit; i++) {
      final step = value.abs() / lipschitzBound * 0.8;
      if (!step.isFinite || step <= 0) break;
      final nextT = math.min(exit, t + step).toDouble();
      final nextValue = field(origin + ray * nextT);
      if ((value < 0) != (nextValue < 0)) {
        return _bisect(origin, ray, t, nextT, value);
      }
      if (nextValue.abs() <= residualTolerance) {
        return _directionalSlope(origin, ray, nextT) < 2e-5
            ? _tangent(nextT, nextValue)
            : _hit(nextT, nextValue);
      }
      if (nextT <= t) break;
      t = nextT;
      value = nextValue;
    }
    return _unresolved(t, value);
  }

  RecursiveSineRayHit _sphereHit(Vector3 origin, Vector3 ray) {
    final interval = _sphereInterval(origin, ray, radius);
    if (interval == null) return _miss;
    final t = interval.$1 >= 0 ? interval.$1 : interval.$2;
    if (t < 0) return _miss;
    final projection = origin.dot(ray);
    final discriminant =
        projection * projection + radius * radius - origin.length2;
    final residual = (origin + ray * t).length - radius;
    return discriminant <= 1e-12 ? _tangent(t, residual) : _hit(t, residual);
  }

  (double, double)? _sphereInterval(Vector3 origin, Vector3 ray, double r) {
    final projection = origin.dot(ray);
    final discriminant = projection * projection + r * r - origin.length2;
    if (!discriminant.isFinite || discriminant < 0) return null;
    final root = math.sqrt(discriminant);
    final near = -projection - root;
    final far = -projection + root;
    if (far < 0) return null;
    return (near, far);
  }

  RecursiveSineRayHit _bisect(
    Vector3 origin,
    Vector3 ray,
    double low,
    double high,
    double lowValue,
  ) {
    for (var i = 0; i < 48; i++) {
      final middle = (low + high) / 2;
      final value = field(origin + ray * middle);
      if (value.abs() <= residualTolerance) return _hit(middle, value);
      if ((value < 0) == (lowValue < 0)) {
        low = middle;
        lowValue = value;
      } else {
        high = middle;
      }
    }
    final t = (low + high) / 2;
    final residual = field(origin + ray * t);
    return residual.abs() <= residualTolerance
        ? _hit(t, residual)
        : _unresolved(t, residual);
  }

  static const _miss = RecursiveSineRayHit(
    RecursiveSineRayStatus.miss,
    double.infinity,
    double.infinity,
  );

  double _directionalSlope(Vector3 origin, Vector3 ray, double t) {
    final point = origin + ray * t;
    return (field(point + ray * 0.001) - field(point - ray * 0.001)).abs();
  }

  RecursiveSineRayHit _hit(double t, double value) => RecursiveSineRayHit(
        RecursiveSineRayStatus.hit,
        t,
        value.abs(),
      );

  RecursiveSineRayHit _tangent(double t, double value) => RecursiveSineRayHit(
        RecursiveSineRayStatus.tangent,
        t,
        value.abs(),
      );

  RecursiveSineRayHit _unresolved(double t, double value) =>
      RecursiveSineRayHit(RecursiveSineRayStatus.unresolved, t, value.abs());

  static void _requireFinite(Vector3 value, String name) {
    if (!value.x.isFinite || !value.y.isFinite || !value.z.isFinite) {
      throw ArgumentError.value(value, name, 'coordinates must be finite');
    }
  }
}

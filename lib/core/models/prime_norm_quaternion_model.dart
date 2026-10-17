import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

typedef IntegerQuaternion = ({int a, int b, int c, int d});

@immutable
class PrimeNormQuaternionSlice {
  static const defaultDomain = 6;
  static const maxDomain = 12;
  static const maxAbsSlice = 12;
  final int bound;
  final int d;
  final List<IntegerQuaternion> points;
  final Uint8List _membership;

  PrimeNormQuaternionSlice._(
      this.bound, this.d, List<IntegerQuaternion> points, this._membership)
      : points = List.unmodifiable(points);

  static int validateDomain(num value) {
    if (!value.isFinite ||
        value < 1 ||
        value > maxDomain ||
        value != value.truncate()) {
      throw ArgumentError.value(value, 'bound', 'Expected integer in 1..12');
    }
    return value.toInt();
  }

  static int validateSlice(num value) {
    if (!value.isFinite ||
        value.abs() > maxAbsSlice ||
        value != value.truncate()) {
      throw ArgumentError.value(value, 'd', 'Expected integer in -12..12');
    }
    return value.toInt();
  }

  bool contains(IntegerQuaternion p) =>
      p.d == d &&
      p.a.abs() <= bound &&
      p.b.abs() <= bound &&
      p.c.abs() <= bound;
  int _index(IntegerQuaternion p) =>
      ((p.a + bound) * (2 * bound + 1) + p.b + bound) * (2 * bound + 1) +
      p.c +
      bound;
  bool isPrimeNorm(IntegerQuaternion p) =>
      contains(p) && _membership[_index(p)] == 1;

  bool isAdjacent(
      IntegerQuaternion from, IntegerQuaternion to, int maxSquaredStep) {
    if (maxSquaredStep < 1 || from.d != d || to.d != d) return false;
    final da = from.a - to.a;
    final db = from.b - to.b;
    final dc = from.c - to.c;
    return isPrimeNorm(from) &&
        isPrimeNorm(to) &&
        da * da + db * db + dc * dc <= maxSquaredStep &&
        da * da + db * db + dc * dc > 0;
  }

  Set<IntegerQuaternion> component(IntegerQuaternion start,
      {required int maxSquaredStep}) {
    if (!isPrimeNorm(start) || maxSquaredStep < 1) return const {};
    final reached = <IntegerQuaternion>{start};
    final queue = <IntegerQuaternion>[start];
    final radius = math.sqrt(maxSquaredStep).floor();
    for (var cursor = 0; cursor < queue.length; cursor++) {
      final point = queue[cursor];
      for (var da = -radius; da <= radius; da++) {
        for (var db = -radius; db <= radius; db++) {
          for (var dc = -radius; dc <= radius; dc++) {
            final distance = da * da + db * db + dc * dc;
            if (distance == 0 || distance > maxSquaredStep) continue;
            final next = (
              a: point.a + da,
              b: point.b + db,
              c: point.c + dc,
              d: d,
            );
            if (isPrimeNorm(next) && reached.add(next)) queue.add(next);
          }
        }
      }
    }
    return Set.unmodifiable(reached);
  }

  static Future<PrimeNormQuaternionSlice> generate(num domain,
      {required num d,
      bool Function()? isCancelled,
      Future<void> Function()? yieldChunk}) async {
    final bound = validateDomain(domain);
    final fixedD = validateSlice(d);
    final maxNorm = 3 * bound * bound + fixedD * fixedD;
    final prime = Uint8List(maxNorm + 1);
    if (maxNorm >= 2) prime.fillRange(2, maxNorm + 1, 1);
    for (var p = 2; p * p <= maxNorm; p++) {
      if (prime[p] == 1) for (var n = p * p; n <= maxNorm; n += p) prime[n] = 0;
    }
    final width = 2 * bound + 1;
    final membership = Uint8List(width * width * width);
    final points = <IntegerQuaternion>[];
    var probes = 0;
    for (var a = -bound; a <= bound; a++) {
      for (var b = -bound; b <= bound; b++) {
        for (var c = -bound; c <= bound; c++) {
          if ((isCancelled?.call() ?? false))
            throw StateError('Generation cancelled');
          final norm = a * a + b * b + c * c + fixedD * fixedD;
          if (prime[norm] == 1) {
            final q = (a: a, b: b, c: c, d: fixedD);
            points.add(q);
            membership[((a + bound) * width + b + bound) * width + c + bound] =
                1;
          }
          if (++probes == 1024) {
            await (yieldChunk?.call() ?? Future<void>.delayed(Duration.zero));
            probes = 0;
          }
        }
      }
    }
    return PrimeNormQuaternionSlice._(bound, fixedD, points, membership);
  }
}

@immutable
class QuaternionProjection {
  final Offset screen;
  final double depth;
  const QuaternionProjection(this.screen, this.depth);
}

class QuaternionSliceCamera {
  double yaw = 0;
  double pitch = 0;

  void rotate(double dx, double dy) {
    yaw += dx;
    pitch = (pitch + dy).clamp(-math.pi / 2, math.pi / 2);
  }

  QuaternionProjection? project(IntegerQuaternion q, Size size, int bound) {
    if (size.isEmpty || bound <= 0) return null;
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final x = q.a * cy - q.b * sy;
    final horizontal = q.a * sy + q.b * cy;
    final y = horizontal * cp - q.c * sp;
    final z = horizontal * sp + q.c * cp;
    final scale = math.min(size.width, size.height) * .42 / bound;
    return QuaternionProjection(
        Offset(size.width / 2 + x * scale, size.height / 2 - y * scale), z);
  }

  IntegerQuaternion? pick(
      Offset screen, PrimeNormQuaternionSlice slice, Size size, int bound,
      {double hitRadius = 24}) {
    IntegerQuaternion? best;
    double? bestDistance, bestDepth;
    for (final q in slice.points) {
      final projected = project(q, size, bound)!;
      final distance = (projected.screen - screen).distanceSquared;
      if (distance > hitRadius * hitRadius) continue;
      final current = best;
      final lexBefore = current != null &&
          (q.a < current.a ||
              q.a == current.a &&
                  (q.b < current.b || q.b == current.b && q.c < current.c));
      if (bestDistance == null ||
          distance < bestDistance ||
          distance == bestDistance &&
              (projected.depth > bestDepth! ||
                  projected.depth == bestDepth && lexBefore)) {
        best = q;
        bestDistance = distance;
        bestDepth = projected.depth;
      }
    }
    return best;
  }
}

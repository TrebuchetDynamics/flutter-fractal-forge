import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Floating-point outcomes, not rigorous certificates for pixels or membership.
enum FibonacciComplexStatus {
  /// Both current moduli passed the sufficient forward-growth region.
  escaped,

  /// No escape detected within the finite update budget; not proven interior.
  capReached,

  /// Invalid input or nonfinite arithmetic prevented a classification.
  numericallyUnresolved,
}

/// Immutable classification and last finite state of H_c(z,w) = (zw+c,z).
///
/// [updates] counts completed updates, with the initial state at zero. On a
/// failed orbit update the preceding finite state is retained. Invalid inputs or
/// an unrepresentable escape radius instead return zero placeholders at update
/// zero; those are not an orbit.
/// No palette or prime-accent choice participates in classification.
@immutable
class FibonacciComplexOrbit {
  final FibonacciComplexStatus status;
  final int updates;
  final double zReal;
  final double zImag;
  final double wReal;
  final double wImag;

  const FibonacciComplexOrbit._(this.status, this.updates, this.zReal,
      this.zImag, this.wReal, this.wImag);
}

/// Family-owned scalar orbit and exact diagonal polynomial-degree metadata.
///
/// Parameter controls normalize c and N at their boundary; this low-level model
/// never clamps a state or silently changes the recurrence. There is no runtime
/// prime search and no extrapolation beyond F47.
abstract final class FibonacciComplexModel {
  static const maxIterations = 45;

  // After k updates the diagonal first-coordinate polynomial is monic of
  // degree F(k+2), for every fixed c. These exact integers also fit on web.
  static const _degrees = [
    1,
    2,
    3,
    5,
    8,
    13,
    21,
    34,
    55,
    89,
    144,
    233,
    377,
    610,
    987,
    1597,
    2584,
    4181,
    6765,
    10946,
    17711,
    28657,
    46368,
    75025,
    121393,
    196418,
    317811,
    514229,
    832040,
    1346269,
    2178309,
    3524578,
    5702887,
    9227465,
    14930352,
    24157817,
    39088169,
    63245986,
    102334155,
    165580141,
    267914296,
    433494437,
    701408733,
    1134903170,
    1836311903,
    2971215073,
  ];
  static const _primeUpdates = {1, 2, 3, 5, 9, 11, 15, 21, 27, 41, 45};

  /// Degree for the diagonal slice only. Reject unknown metadata indices.
  static int degreeAtUpdate(int k) => _degrees[k];

  static bool isPrimeDegreeAtUpdate(int k) {
    RangeError.checkValidIndex(k, _degrees, 'k');
    return _primeUpdates.contains(k);
  }

  /// Inspect k=0, then simultaneously update from OLD z,w and inspect k=1..N.
  ///
  /// Omitted w components default to the matching z components (the diagonal
  /// initial slice). Explicit w supports the full map, not a diagonal invariant.
  /// N must be 1..45 and bailout positive and finite; invalid low-level inputs
  /// return numerical uncertainty. Finite c is accepted without clamping; UI
  /// controls are responsible for their narrower [-2,2] component bounds.
  static FibonacciComplexOrbit orbit({
    required double zReal,
    required double zImag,
    double? wReal,
    double? wImag,
    required double cReal,
    required double cImag,
    int maxIterations = FibonacciComplexModel.maxIterations,
    double bailout = 4,
  }) {
    var zr = zReal, zi = zImag;
    var wr = wReal ?? zr, wi = wImag ?? zi;
    if (!zr.isFinite ||
        !zi.isFinite ||
        !wr.isFinite ||
        !wi.isFinite ||
        !cReal.isFinite ||
        !cImag.isFinite ||
        !bailout.isFinite ||
        bailout <= 0 ||
        maxIterations < 1 ||
        maxIterations > FibonacciComplexModel.maxIterations) {
      return const FibonacciComplexOrbit._(
          FibonacciComplexStatus.numericallyUnresolved, 0, 0, 0, 0, 0);
    }

    final radius = math.max(2 + _magnitude(cReal, cImag), bailout);
    if (!radius.isFinite) {
      return const FibonacciComplexOrbit._(
          FibonacciComplexStatus.numericallyUnresolved, 0, 0, 0, 0, 0);
    }
    for (var k = 0; k <= maxIterations; k++) {
      // In exact arithmetic q = R - |c|/R > 1 gives forward growth.
      // Check BOTH components before multiplication, including at k=0 and N.
      if (_exceedsRadius(zr, zi, radius) && _exceedsRadius(wr, wi, radius)) {
        return FibonacciComplexOrbit._(
            FibonacciComplexStatus.escaped, k, zr, zi, wr, wi);
      }
      if (k == maxIterations) {
        return FibonacciComplexOrbit._(
            FibonacciComplexStatus.capReached, k, zr, zi, wr, wi);
      }
      final nextReal = zr * wr - zi * wi + cReal;
      final nextImag = zr * wi + zi * wr + cImag;
      if (!nextReal.isFinite || !nextImag.isFinite) {
        return FibonacciComplexOrbit._(
            FibonacciComplexStatus.numericallyUnresolved, k, zr, zi, wr, wi);
      }
      wr = zr;
      wi = zi;
      zr = nextReal;
      zi = nextImag;
    }
    throw StateError('Orbit must terminate at its update cap');
  }

  // Scaled hypot avoids squaring overflow/underflow for finite components.
  // If even the modulus of c overflows, the radius is unresolved, not escape.
  static double _magnitude(double real, double imag) {
    final scale = math.max(real.abs(), imag.abs());
    if (scale == 0) return 0;
    final ratio = math.min(real.abs(), imag.abs()) / scale;
    return scale * math.sqrt(1 + ratio * ratio);
  }

  // Compare without forming a potentially unrepresentable state modulus.
  static bool _exceedsRadius(double real, double imag, double radius) {
    final scale = math.max(real.abs(), imag.abs());
    if (scale > radius) return true;
    if (scale == 0) return false;
    final ratio = math.min(real.abs(), imag.abs()) / scale;
    return scale > radius / math.sqrt(1 + ratio * ratio);
  }
}

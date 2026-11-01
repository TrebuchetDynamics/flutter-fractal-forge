// Pure complex-number arithmetic shared by the CPU fractal renderer.
//
// Complex values are represented as plain `(double re, double im)` records so
// the helpers stay allocation-free and close to their GPU shader counterparts
// under shaders/*.frag. The `*Safe` variants guard against the singularities
// (log/div by zero, exp overflow) that escape-time iteration can otherwise hit.
// Every function here is pure and side-effect free.

import 'dart:math' as math;

import 'cpu_scalar_math.dart';

/// Complex multiply: `(a) * (b)`.
(double re, double im) cmul(double ax, double ay, double bx, double by) {
  return (ax * bx - ay * by, ax * by + ay * bx);
}

/// Complex divide `(a) / (b)`, guarded so a near-zero denominator cannot blow
/// up to Infinity/NaN.
@pragma('vm:prefer-inline')
(double re, double im) cdivSafe(double ax, double ay, double bx, double by) {
  final d = math.max(1e-20, bx * bx + by * by);
  return ((ax * bx + ay * by) / d, (ay * bx - ax * by) / d);
}

/// Principal complex logarithm, guarded against `log(0)`.
@pragma('vm:prefer-inline')
(double re, double im) clogSafe(double ax, double ay) {
  final r2 = math.max(1e-20, ax * ax + ay * ay);
  return (0.5 * math.log(r2), math.atan2(ay, ax));
}

/// Complex exponential, with the real part clamped to `[-clampX, clampX]` to
/// avoid `exp` overflowing to Infinity.
@pragma('vm:prefer-inline')
(double re, double im) cexpSafe(double ax, double ay, {double clampX = 80.0}) {
  final ex = math.exp(clampDouble(ax, -clampX, clampX));
  return (ex * math.cos(ay), ex * math.sin(ay));
}

/// Complex power `a^b` via `exp(b * log(a))`, using the guarded log/exp above.
@pragma('vm:prefer-inline')
(double re, double im) cpowSafe(double ax, double ay, double bx, double by) {
  final logA = clogSafe(ax, ay);
  final prod = cmul(bx, by, logA.$1, logA.$2);
  return cexpSafe(prod.$1, prod.$2);
}

/// Integer complex power `z^n` by repeated multiplication (exact, no log/exp).
(double re, double im) cpowInt(double zx, double zy, int n) {
  double rx = 1.0, ry = 0.0;
  for (int i = 0; i < n; i++) {
    final nx = rx * zx - ry * zy;
    final ny = rx * zy + ry * zx;
    rx = nx;
    ry = ny;
  }
  return (rx, ry);
}

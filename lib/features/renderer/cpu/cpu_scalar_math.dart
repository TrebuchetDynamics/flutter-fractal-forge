// Pure scalar math helpers shared by the CPU fractal renderer.
//
// These mirror common GLSL built-ins (`fract`, `clamp`, `mix`, `smoothstep`,
// `mod`) plus a few hyperbolic/log helpers, so the CPU formulas can stay close
// to their GPU shader counterparts under shaders/*.frag. Every function here is
// pure and side-effect free, which makes them safe to share and easy to test in
// isolation.

import 'dart:math' as math;

/// Base-2 logarithm, guarded against non-positive input.
///
/// Returns `log2(max(1e-16, x))`. The clamp prevents NaN/-Infinity from
/// propagating out of nested calls such as `log2(log2(m2))` when the inner
/// result is <= 0 (i.e. `m2 < 1`), which is reachable from the smooth-escape
/// colouring path.
double log2(double x) => math.log(math.max(1e-16, x)) / math.ln2;

/// Fractional part of [x] (GLSL `fract`): `x - floor(x)`. Always in `[0, 1)`.
double fract(double x) => x - x.floorToDouble();

/// Clamps [x] to the inclusive range `[lower, upper]` (GLSL `clamp`).
///
/// Assumes `lower <= upper`; callers that cannot guarantee ordering should sort
/// the bounds first.
double clampDouble(double x, double lower, double upper) =>
    x < lower ? lower : (x > upper ? upper : x);

/// Linear interpolation between [a] and [b] by [t] (GLSL `mix`).
double mix(double a, double b, double t) => a + (b - a) * t;

/// GLSL `smoothstep`: 0 below [edge0], 1 above [edge1], Hermite-smoothed in
/// between.
///
/// When `edge0 == edge1` the transition is degenerate; this returns a hard step
/// at that edge instead of dividing by zero (which would yield NaN).
double smoothstep(double edge0, double edge1, double x) {
  if (edge0 == edge1) return x < edge0 ? 0.0 : 1.0;
  final t = clampDouble((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}

/// Floored modulo (GLSL `mod`): the result takes the sign of [y].
double floorMod(double x, double y) => x - y * (x / y).floorToDouble();

/// Hyperbolic sine.
double sinh(double x) => (math.exp(x) - math.exp(-x)) * 0.5;

/// Hyperbolic cosine.
double cosh(double x) => (math.exp(x) + math.exp(-x)) * 0.5;

/// Hyperbolic tangent, computed in a numerically stable form.
double tanh(double x) {
  final e2x = math.exp(2.0 * x);
  return (e2x - 1.0) / (e2x + 1.0);
}

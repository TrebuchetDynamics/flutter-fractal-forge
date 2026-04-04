// CPU formula utilities - shared helper functions for all fractal families.
//
// This file contains the common infrastructure used by all CPU formula
// implementations including math utilities, color functions, and escape-time
// iteration helpers.

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

/// CPU formula function signature.
/// Returns RGB values as a record of three doubles (0-255 range).
typedef CpuFormula = (double r, double g, double b) Function(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
);

/// Default inside color (blue-ish) for points that don't escape.
const (double r, double g, double b) insideColor = (46.0, 120.0, 220.0);

// ---------------------------------------------------------------------------
// Math utilities
// ---------------------------------------------------------------------------

/// Log base 2.
double log2(double x) => math.log(x) / math.ln2;

/// Fractional part of a number.
double fract(double x) => x - x.floorToDouble();

/// Clamp value to range [a, b].
double clamp(double x, double a, double b) => x < a ? a : (x > b ? b : x);

/// Linear interpolation between a and b.
double mix(double a, double b, double t) => a + (b - a) * t;

/// Smoothstep interpolation.
double smoothstep(double edge0, double edge1, double x) {
  final t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}

/// Modulo operation.
double mod(double x, double y) => x - y * (x / y).floorToDouble();

/// Hyperbolic sine.
double sinh(double x) => (math.exp(x) - math.exp(-x)) * 0.5;

/// Hyperbolic cosine.
double cosh(double x) => (math.exp(x) + math.exp(-x)) * 0.5;

/// Hyperbolic tangent.
double tanh(double x) {
  final e2x = math.exp(2.0 * x);
  return (e2x - 1.0) / (e2x + 1.0);
}

/// FNV-1a 32-bit hash function.
int fnv1a32(String s) {
  int h = 0x811c9dc5;
  for (final cu in s.codeUnits) {
    h ^= cu;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

// ---------------------------------------------------------------------------
// Complex number operations
// ---------------------------------------------------------------------------

/// Complex multiplication: (ax + i*ay) * (bx + i*by)
@pragma('vm:prefer-inline')
(double x, double y) cmul(double ax, double ay, double bx, double by) {
  return (ax * bx - ay * by, ax * by + ay * bx);
}

/// Complex division with safety check.
@pragma('vm:prefer-inline')
(double x, double y) cdivSafe(double ax, double ay, double bx, double by) {
  final d = math.max(1e-20, bx * bx + by * by);
  return ((ax * bx + ay * by) / d, (ay * bx - ax * by) / d);
}

/// Complex logarithm with safety check.
@pragma('vm:prefer-inline')
(double x, double y) clogSafe(double ax, double ay) {
  final r2 = math.max(1e-20, ax * ax + ay * ay);
  return (0.5 * math.log(r2), math.atan2(ay, ax));
}

/// Complex exponential with clamped input.
@pragma('vm:prefer-inline')
(double x, double y) cexpSafe(double ax, double ay, {double clampX = 80.0}) {
  final ex = math.exp(clamp(ax, -clampX, clampX));
  return (ex * math.cos(ay), ex * math.sin(ay));
}

/// Complex power: z^w where z = ax+i*ay, w = bx+i*by
@pragma('vm:prefer-inline')
(double x, double y) cpowSafe(double ax, double ay, double bx, double by) {
  final logA = clogSafe(ax, ay);
  final prod = cmul(bx, by, logA.$1, logA.$2);
  return cexpSafe(prod.$1, prod.$2);
}

/// Complex integer power: z^n for n >= 0.
@pragma('vm:prefer-inline')
(double, double) cpowInt(double zx, double zy, int n) {
  double rx = 1.0, ry = 0.0;
  for (int i = 0; i < n; i++) {
    final nx = rx * zx - ry * zy;
    final ny = rx * zy + ry * zx;
    rx = nx;
    ry = ny;
  }
  return (rx, ry);
}

// ---------------------------------------------------------------------------
// Color functions
// ---------------------------------------------------------------------------

/// Cosine-based color palette.
(double r, double g, double b) palette(double t) {
  final r = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.00))) * 255.0;
  final g = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.33))) * 255.0;
  final b = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.67))) * 255.0;
  return (r, g, b);
}

/// HSV to RGB conversion (h,s,v all 0..1) → (r,g,b) 0..255.
(double r, double g, double b) hsv2rgb(double h, double s, double v) {
  final c = v * s;
  final x = c * (1.0 - ((h * 6.0) % 2.0 - 1.0).abs());
  final m = v - c;
  double r, g, b;
  final sector = (h * 6.0).floor() % 6;
  switch (sector) {
    case 0:
      r = c;
      g = x;
      b = 0;
    case 1:
      r = x;
      g = c;
      b = 0;
    case 2:
      r = 0;
      g = c;
      b = x;
    case 3:
      r = 0;
      g = x;
      b = c;
    case 4:
      r = x;
      g = 0;
      b = c;
    default:
      r = c;
      g = 0;
      b = x;
  }
  return ((r + m) * 255.0, (g + m) * 255.0, (b + m) * 255.0);
}

// ---------------------------------------------------------------------------
// Escape-time utilities
// ---------------------------------------------------------------------------

/// Calculate smooth escape value for coloring.
double smoothEscape({
  required int it,
  required int iterations,
  required double mag2,
  double power = 2.0,
}) {
  final m2 = math.max(1e-16, mag2);
  final lp = log2(power);
  final v = it - log2(log2(m2)) / (lp == 0.0 ? 1.0 : lp);
  return fract(v / 64.0);
}

/// Gamma function using Stirling approximation.
(double x, double y) gammaStirling(double zx, double zy) {
  // Stirling approximation Γ(z) ≈ sqrt(2π) z^(z-1/2) e^{-z}
  var zsx = zx;
  var zsy = zy;
  if (zsx < 0.15) zsx = 0.15; // keep away from branch/poles

  final logZ = clogSafe(zsx, zsy); // (log(r), atan)
  final power = cmul(zsx - 0.5, zsy, logZ.$1, logZ.$2);

  final logGammaX = 0.5 * math.log(2.0 * math.pi) + power.$1 - zsx;
  final logGammaY = power.$2 - zsy;

  return cexpSafe(logGammaX, logGammaY, clampX: 40.0);
}

/// Function type for Z update in escape-time iteration.
typedef ZUpdate = (double, double) Function(
    double zx, double zy, double cx, double cy);

/// Higher-order escape-time formula.
///
/// Runs the standard escape-time loop using [update] as the recurrence, then
/// colours using [smoothEscape] + [palette]. Optional [zx0]/[zy0] override
/// the initial z value (default 0+0i). [power] forwards to [smoothEscape].
@pragma('vm:prefer-inline')
(double r, double g, double b) escapeTime(
  double x,
  double y,
  int iterations,
  double bailout,
  ZUpdate update, {
  double zx0 = 0.0,
  double zy0 = 0.0,
  double power = 2.0,
}) {
  double zx = zx0;
  double zy = zy0;
  final bailout2 = bailout * bailout;
  int it = 0;
  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;
    final n = update(zx, zy, x, y);
    zx = n.$1;
    zy = n.$2;
    it++;
  }
  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  return palette(
    smoothEscape(it: it, iterations: iterations, mag2: mag2, power: power),
  );
}

// ---------------------------------------------------------------------------
// Noise functions (for advanced formulas)
// ---------------------------------------------------------------------------

/// 2D hash function.
double hash21(double px, double py) {
  var qx = (px * 443.8975) % 1.0;
  var qy = (py * 397.2973) % 1.0;
  if (qx < 0) qx += 1.0;
  if (qy < 0) qy += 1.0;
  final d = qx * qy + (qx + qy) * 19.19;
  return (d * 43758.5453) % 1.0;
}

/// Simple value noise approximation.
double simplexNoise2D(double px, double py) {
  final ix = px.floorToDouble();
  final iy = py.floorToDouble();
  final fx = px - ix;
  final fy = py - iy;
  final ux = fx * fx * (3.0 - 2.0 * fx);
  final uy = fy * fy * (3.0 - 2.0 * fy);
  final n00 = hash21(ix, iy);
  final n10 = hash21(ix + 1, iy);
  final n01 = hash21(ix, iy + 1);
  final n11 = hash21(ix + 1, iy + 1);
  return mix(mix(n00, n10, ux), mix(n01, n11, ux), uy);
}

// ---------------------------------------------------------------------------
// Synthetic fallback formula
// ---------------------------------------------------------------------------

/// Deterministic synthetic fallback for formulas without native CPU implementation.
///
/// Provides a visually distinct CPU render per module id so the CPU backend
/// covers the whole catalog without going black. This is intentionally
/// lightweight and stable: no RNG, no allocations.
(double r, double g, double b) cpuSynthetic(
  int seed,
  double x,
  double y,
  int iterations,
  double bailout,
) {
  final s = seed & 0xffffffff;

  final a = 0.12 + ((s & 0xff) / 255.0) * 0.88;
  final b = 0.12 + (((s >> 8) & 0xff) / 255.0) * 0.88;
  final c = 0.20 + (((s >> 16) & 0xff) / 255.0) * 0.80;
  final d = 0.20 + (((s >> 24) & 0xff) / 255.0) * 0.80;

  final flipX = (s & 1) != 0;
  final flipY = (s & 2) != 0;
  final initMode = (s >> 2) & 3;

  final cx = x;
  final cy = y;

  double zx;
  double zy;
  switch (initMode) {
    case 0:
      zx = 0.0;
      zy = 0.0;
      break;
    case 1:
      zx = cx;
      zy = cy;
      break;
    case 2:
      zx = cx * 0.5;
      zy = cy * 0.5;
      break;
    default:
      zx = cx;
      zy = -cy;
      break;
  }

  final br = math.max(2.0, bailout);
  final bailout2 = (br * br) * (4.0 + 2.0 * a);
  final theta = (a - b) * 0.35;
  final ct = math.cos(theta);
  final st = math.sin(theta);

  int it = 0;
  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) break;

    // Base quadratic map + seeded nonlinear warping.
    final qx = zx * zx - zy * zy + cx;
    final qy = 2.0 * zx * zy + cy;

    double nx = qx + a * math.sin(c * qy) - b * math.cos(d * qx);
    double ny = qy + a * math.sin(d * qx) + b * math.cos(c * qy);

    if (flipX) nx = nx.abs();
    if (flipY) ny = ny.abs();

    // Small rotation for additional diversity.
    final rx = nx * ct - ny * st;
    final ry = nx * st + ny * ct;
    zx = rx;
    zy = ry;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final baseT = smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  final offset = ((s ^ (s >> 13)) & 1023) / 1024.0;
  return palette(fract(baseT + offset));
}

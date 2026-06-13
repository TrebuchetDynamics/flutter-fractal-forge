// Shared escape-time engine and colouring for the CPU fractal renderer.
//
// This is the core that virtually every escape-time formula in cpu_formulas.dart
// builds on: a generic iteration driver ([escapeTime]) plus the colouring
// primitives ([palette], [smoothEscape], [kInsideColor]). Keeping it in one small
// module lets the formula definitions stay declarative (just a recurrence) and
// makes the engine reusable and testable in isolation.

import 'dart:math' as math;

import 'cpu_scalar_math.dart';

/// Fill colour for points that never escape, i.e. the interior of the set.
const (double r, double g, double b) kInsideColor = (46.0, 120.0, 220.0);

/// Cosine palette: maps a normalized parameter [t] to an RGB triple in
/// `[0, 255]`. The three channels are phase-shifted cosines, giving a smooth
/// cyclic gradient (the classic Inigo Quilez palette shape).
@pragma('vm:prefer-inline')
(double r, double g, double b) palette(double t) {
  final r = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.00))) * 255.0;
  final g = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.33))) * 255.0;
  final b = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.67))) * 255.0;
  return (r, g, b);
}

/// Continuous (smooth) escape colouring index.
///
/// Converts an integer escape iteration [it] plus the final magnitude-squared
/// [mag2] into a fractional palette position, removing the banding that raw
/// iteration counts produce. [power] is the degree of the recurrence (2 for the
/// classic Mandelbrot z^2 + c). The result is wrapped to `[0, 1)` via [fract].
double smoothEscape({
  required int it,
  required double mag2,
  double power = 2.0,
}) {
  final m2 = math.max(1e-16, mag2);
  final lp = log2(power);
  final v = it - log2(log2(m2)) / (lp == 0.0 ? 1.0 : lp);
  return fract(v / 64.0);
}

/// Recurrence callback for [escapeTime]: maps the current `z = (zx, zy)` and the
/// constant `c = (cx, cy)` to the next `z`.
typedef ZUpdate = (double, double) Function(
    double zx, double zy, double cx, double cy);

/// Generic escape-time driver.
///
/// Iterates [update] from the initial `z = (zx0, zy0)` until `|z|` exceeds
/// [bailout] or [iterations] is reached, then colours the result with
/// [smoothEscape] + [palette]. Interior points return [kInsideColor]. [power]
/// forwards to [smoothEscape] for correct smoothing of higher-degree maps.
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
  if (it >= iterations) return kInsideColor;
  final mag2 = zx * zx + zy * zy;
  return palette(
    smoothEscape(it: it, mag2: mag2, power: power),
  );
}

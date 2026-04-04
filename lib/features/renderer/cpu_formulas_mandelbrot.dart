// Core Mandelbrot family formulas.
//
// Classic Mandelbrot, Julia, Phoenix, and Burning Ship variants.

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Core Mandelbrot Family
// ---------------------------------------------------------------------------

/// Classic Mandelbrot set: z = z^2 + c
(double r, double g, double b) cpuMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, 2.0 * zx * zy + cy));

/// Julia set: z₀ = (x, y), c = juliaC
(double r, double g, double b) cpuJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final c0x = juliaC.x;
  final c0y = juliaC.y;
  return escapeTime(
    x,
    y,
    iterations,
    bailout,
    (zx, zy, cx, cy) => (zx * zx - zy * zy + c0x, 2.0 * zx * zy + c0y),
    zx0: x,
    zy0: y,
  );
}

/// Phoenix recurrence: z(n+1) = z(n)^2 + c + p*z(n-1)
(double r, double g, double b) cpuPhoenix(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const p = -0.5;
  final cx = juliaC.x;
  final cy = juliaC.y;

  double zx = x;
  double zy = y;
  double zPrevX = 0.0;
  double zPrevY = 0.0;

  final bailout2 = bailout * bailout;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final nx = zx * zx - zy * zy + cx + p * zPrevX;
    final ny = 2.0 * zx * zy + cy + p * zPrevY;

    zPrevX = zx;
    zPrevY = zy;
    zx = nx;
    zy = ny;

    if (zx * zx + zy * zy > bailout2) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  return palette(smoothEscape(it: it, iterations: iterations, mag2: mag2));
}

// ---------------------------------------------------------------------------
// Burning Ship Variants
// ---------------------------------------------------------------------------

/// Burning Ship: z = (|Re(z)| + i|Im(z)|)^2 + c (with Y-flip)
(double r, double g, double b) cpuBurningShip(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      return (ax * ax - ay * ay + cx, 2.0 * ax * ay + cy);
    });

/// Burning Ship Cubic: power 3 variant
(double r, double g, double b) cpuBurningShipCubic(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      return (ax * w2x - ay * w2y + cx, ax * w2y + ay * w2x + cy);
    }, power: 3.0);

/// Burning Ship Power 4
(double r, double g, double b) cpuBurningShipPower4(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      return (w4x + cx, w4y + cy);
    }, power: 4.0);

/// Burning Ship Power 5
(double r, double g, double b) cpuBurningShipPower5(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      final w5x = w4x * ax - w4y * ay;
      final w5y = w4x * ay + w4y * ax;
      return (w5x + cx, w5y + cy);
    }, power: 5.0);

/// Burning Ship Power 6
(double r, double g, double b) cpuBurningShipPower6(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      final w6x = w4x * w2x - w4y * w2y;
      final w6y = w4x * w2y + w4y * w2x;
      return (w6x + cx, w6y + cy);
    }, power: 6.0);

/// Burning Ship Power 7
(double r, double g, double b) cpuBurningShipPower7(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w3x = ax * w2x - ay * w2y;
      final w3y = ax * w2y + ay * w2x;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      final w7x = w4x * w3x - w4y * w3y;
      final w7y = w4x * w3y + w4y * w3x;
      return (w7x + cx, w7y + cy);
    }, power: 7.0);

/// Burning Ship Julia variant
(double r, double g, double b) cpuBurningShipJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9921bde9, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Celtic Variants
// ---------------------------------------------------------------------------

/// Celtic: z = |Re(z^2)| + i*Im(z^2) + c
(double r, double g, double b) cpuCeltic(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(
        x,
        y,
        iterations,
        bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, 2.0 * zx * zy + cy));

/// Celtic Cubic
(double r, double g, double b) cpuCelticCubic(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      final x3 = zx * (x2 - 3.0 * y2);
      final y3 = zy * (3.0 * x2 - y2);
      return (x3.abs() + cx, y3 + cy);
    }, power: 3.0);

/// Celtic Power 4
(double r, double g, double b) cpuCelticPower4(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      return (z4x.abs() + cx, z4y + cy);
    }, power: 4.0);

/// Celtic Power 5
(double r, double g, double b) cpuCelticPower5(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      final z5x = z4x * zx - z4y * zy;
      final z5y = z4x * zy + z4y * zx;
      return (z5x.abs() + cx, z5y + cy);
    }, power: 5.0);

/// Celtic Julia
(double r, double g, double b) cpuCelticJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x361c54b7, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Buffalo Variants
// ---------------------------------------------------------------------------

/// Buffalo: z = |Re(z^2)| + i|Im(z^2)| + c
(double r, double g, double b) cpuBuffalo(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(
        x,
        y,
        iterations,
        bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, (2.0 * zx * zy).abs() + cy));

/// Buffalo Cubic
(double r, double g, double b) cpuBuffaloCubic(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      final x3 = zx * (x2 - 3.0 * y2);
      final y3 = zy * (3.0 * x2 - y2);
      return (x3.abs() + cx, y3.abs() + cy);
    }, power: 3.0);

/// Buffalo Julia
(double r, double g, double b) cpuBuffaloJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xa164daa4, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Multibrot Variants
// ---------------------------------------------------------------------------

/// Multibrot (power 3): z = z^3 + c
(double r, double g, double b) cpuMultibrot3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      return (zx * (x2 - 3.0 * y2) + cx, zy * (3.0 * x2 - y2) + cy);
    }, power: 3.0);

/// Multibrot (power 4): z = z^4 + c
(double r, double g, double b) cpuMultibrot4(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      return (z4x + cx, z4y + cy);
    }, power: 4.0);

/// Multibrot (power 5): z = z^5 + c
(double r, double g, double b) cpuMultibrot5(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      final z5x = z4x * zx - z4y * zy;
      final z5y = z4x * zy + z4y * zx;
      return (z5x + cx, z5y + cy);
    }, power: 5.0);

/// Multibrot (power -2): z = z^-2 + c
(double r, double g, double b) cpuMultibrotNeg2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x171f3266, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Tricorn and Perpendicular Variants
// ---------------------------------------------------------------------------

/// Tricorn (Mandelbar): z = conj(z)^2 + c
(double r, double g, double b) cpuTricorn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, -2.0 * zx * zy + cy));

/// Tricorn Julia
(double r, double g, double b) cpuTricornJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xc961b542, x, y, iterations, bailout);

/// Perpendicular Mandelbrot
(double r, double g, double b) cpuPerpendicularMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(
        x,
        y,
        iterations,
        bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, 2.0 * zx * zy + cy));

/// Perpendicular Julia
(double r, double g, double b) cpuPerpendicularJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xaae2dafd, x, y, iterations, bailout);

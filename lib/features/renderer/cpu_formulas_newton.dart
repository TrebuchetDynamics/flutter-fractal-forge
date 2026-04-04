// Newton and root-finding method formulas.
//
// This file contains fractals based on Newton's method, Halley's method,
// Householder's method, and other root-finding algorithms.

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Newton's Method Variants
// ---------------------------------------------------------------------------

/// Newton z^3 - 1
(double r, double g, double b) cpuNewtonZ3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xdce85dc4, x, y, iterations, bailout);

/// Newton sin(z)
(double r, double g, double b) cpuNewtonSin(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x88601b9b, x, y, iterations, bailout);

/// Newton general (polynomial)
(double r, double g, double b) cpuNewtonGeneral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf807a375, x, y, iterations, bailout);

/// Damped Newton with alpha parameter
(double r, double g, double b) cpuDampedNewton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const double alpha = 1.0;
  const int degree = 3;

  double zx = x;
  double zy = y;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;
    final fx = z3x - 1.0;
    final fy = z3y;
    final fpx = 3.0 * z2x;
    final fpy = 3.0 * z2y;
    final step = cdivSafe(fx, fy, fpx, fpy);
    zx -= alpha * step.$1;
    zy -= alpha * step.$2;

    if (step.$1 * step.$1 + step.$2 * step.$2 < 1e-12) {
      it = j;
      break;
    }
    if (zx * zx + zy * zy > bailout * bailout) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;

  double bestDist = 1e10;
  double rootPhase = 0.0;
  for (int k = 0; k < degree; k++) {
    final angle = 6.28318 * k / degree;
    final rx = math.cos(angle);
    final ry = math.sin(angle);
    final dx = zx - rx;
    final dy = zy - ry;
    final dist = dx * dx + dy * dy;
    if (dist < bestDist) {
      bestDist = dist;
      rootPhase = k / degree;
    }
  }
  return palette(fract(it / math.max(1.0, iterations.toDouble()) + rootPhase));
}

/// Durand-Kerner simultaneous root-finding
(double r, double g, double b) cpuDurandKerner(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const int degree = 3;
  double zx = x;
  double zy = y;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final z2 = cmul(zx, zy, zx, zy);
    final z3 = cmul(z2.$1, z2.$2, zx, zy);
    final fx = z3.$1 - 1.0;
    final fy = z3.$2;
    final fpx = 3.0 * z2.$1;
    final fpy = 3.0 * z2.$2;
    final corr = cdivSafe(fx, fy, fpx - 0.5 * fx, fpy - 0.5 * fy);
    zx -= corr.$1;
    zy -= corr.$2;

    if (corr.$1 * corr.$1 + corr.$2 * corr.$2 < 1e-12) {
      it = j;
      break;
    }
    if (zx * zx + zy * zy > bailout * bailout) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;
  double bestDist = 1e10;
  double rootPhase = 0.0;
  for (int k = 0; k < degree; k++) {
    final angle = 6.28318 * k / degree;
    final dx = zx - math.cos(angle);
    final dy = zy - math.sin(angle);
    final dist = dx * dx + dy * dy;
    if (dist < bestDist) {
      bestDist = dist;
      rootPhase = k / degree;
    }
  }
  return palette(fract(it / math.max(1.0, iterations.toDouble()) + rootPhase));
}

/// Ehrlich-Aberth root-finding
(double r, double g, double b) cpuEhrlichAberth(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const int degree = 3;
  double zx = x;
  double zy = y;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final z2 = cmul(zx, zy, zx, zy);
    final z3 = cmul(z2.$1, z2.$2, zx, zy);
    final fx = z3.$1 - 1.0;
    final fy = z3.$2;
    final fpx = 3.0 * z2.$1;
    final fpy = 3.0 * z2.$2;
    final fppx = 6.0 * zx;
    final fppy = 6.0 * zy;
    final ratio = cdivSafe(fx, fy, fpx, fpy);
    final halfRatioTimesSecond = cmul(ratio.$1, ratio.$2, fppx, fppy);
    final corrDivX = 1.0 -
        0.5 *
            cdivSafe(halfRatioTimesSecond.$1, halfRatioTimesSecond.$2, fpx, fpy)
                .$1;
    final corrDivY = -0.5 *
        cdivSafe(halfRatioTimesSecond.$1, halfRatioTimesSecond.$2, fpx, fpy).$2;
    final step = cdivSafe(ratio.$1, ratio.$2, corrDivX, corrDivY);
    zx -= step.$1;
    zy -= step.$2;

    if (step.$1 * step.$1 + step.$2 * step.$2 < 1e-12) {
      it = j;
      break;
    }
    if (zx * zx + zy * zy > bailout * bailout) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;
  double bestDist = 1e10;
  double rootPhase = 0.0;
  for (int k = 0; k < degree; k++) {
    final angle = 6.28318 * k / degree;
    final dx = zx - math.cos(angle);
    final dy = zy - math.sin(angle);
    final dist = dx * dx + dy * dy;
    if (dist < bestDist) {
      bestDist = dist;
      rootPhase = k / degree;
    }
  }
  return palette(fract(it / math.max(1.0, iterations.toDouble()) + rootPhase));
}

// ---------------------------------------------------------------------------
// Halley and Householder Methods
// ---------------------------------------------------------------------------

/// Halley's method
(double r, double g, double b) cpuHalley(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x85194b64, x, y, iterations, bailout);

/// Householder's method
(double r, double g, double b) cpuHouseholder(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x13a1358d, x, y, iterations, bailout);

// ---------------------------------------------------------------------------
// Magnet Fractals
// ---------------------------------------------------------------------------

/// Magnet type 1 (Newton-like with complex rational function)
(double r, double g, double b) cpuMagnetType1(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) break;

    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;

    final numx = z2x + cx - 1.0;
    final numy = z2y + cy;
    final denx = 2.0 * zx + cx - 2.0;
    final deny = 2.0 * zy + cy;

    final q = cdivSafe(numx, numy, denx, deny);
    final qx = q.$1;
    final qy = q.$2;

    zx = qx * qx - qy * qy;
    zy = 2.0 * qx * qy;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return palette(t);
}

/// Magnet type 2
(double r, double g, double b) cpuMagnetType2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;

  final c2x = cx * cx - cy * cy;
  final c2y = 2.0 * cx * cy;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) break;

    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;

    final c1x = cx - 1.0;
    final c1y = cy;
    final c1zx = c1x * zx - c1y * zy;
    final c1zy = c1x * zy + c1y * zx;

    final c2mx = cx - 2.0;
    final c2my = cy;
    final c2zx = c2mx * zx - c2my * zy;
    final c2zy = c2mx * zy + c2my * zx;

    final numx = z3x + 3.0 * c1zx + c2x - 1.0;
    final numy = z3y + 3.0 * c1zy + c2y;

    final denx = 3.0 * z2x + 3.0 * c2zx + c2x - cx + 3.0;
    final deny = 3.0 * z2y + 3.0 * c2zy + c2y - cy;

    final q = cdivSafe(numx, numy, denx, deny);
    final qx = q.$1;
    final qy = q.$2;

    zx = qx * qx - qy * qy;
    zy = 2.0 * qx * qy;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return palette(t);
}

/// Magnet type 3
(double r, double g, double b) cpuMagnetType3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final px = x;
  final py = y;
  double zx = px;
  double zy = py;

  const kAx = 0.42;
  const kAy = -0.18;
  const kBx = -0.31;
  const kBy = 0.24;
  const kCx = 0.73;
  const kCy = 0.11;
  const kDx = -0.26;
  const kDy = -0.39;
  const kEx = 0.85;
  const kEy = 0.07;

  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) break;

    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;
    final z4x = z2x * z2x - z2y * z2y;
    final z4y = 2.0 * z2x * z2y;

    final kAz2x = kAx * z2x - kAy * z2y;
    final kAz2y = kAx * z2y + kAy * z2x;
    final numx = z4x + kAz2x + kBx;
    final numy = z4y + kAz2y + kBy;

    final kCz3x = kCx * z3x - kCy * z3y;
    final kCz3y = kCx * z3y + kCy * z3x;
    final kDzx = kDx * zx - kDy * zy;
    final kDzy = kDx * zy + kDy * zx;
    final denx = kCz3x + kDzx + kEx;
    final deny = kCz3y + kDzy + kEy;

    final q = cdivSafe(numx, numy, denx, deny);
    final qx = q.$1;
    final qy = q.$2;

    final q2x = qx * qx - qy * qy;
    final q2y = 2.0 * qx * qy;
    zx = q2x + 0.12 * px;
    zy = q2y + 0.12 * py;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return palette(t);
}

/// Magnet Newton variant
(double r, double g, double b) cpuMagnetNewton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x6d478757, x, y, iterations, bailout);

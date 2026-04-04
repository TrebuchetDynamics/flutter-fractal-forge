// Core fractal variants - Nova, Fatou, Gamma, and special polynomials.
//
// This file contains Nova, Fatou, Gamma, Lambda, and other escape-time
// variants that build upon the Mandelbrot family.

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Nova Fractals
// ---------------------------------------------------------------------------

/// Nova: Newton on z^3 - 1 with +c perturbation
(double r, double g, double b) cpuNova(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final cx = x;
  final cy = y;
  double zx = 1.0;
  double zy = 0.0;
  final R = bailout;

  int it = iterations;
  for (int j = 0; j < iterations; j++) {
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;

    final fzx = z3x - 1.0;
    final fzy = z3y;
    final fpx = 3.0 * z2x;
    final fpy = 3.0 * z2y;

    final d = math.max(1e-20, fpx * fpx + fpy * fpy);
    final stepx = (fzx * fpx + fzy * fpy) / d;
    final stepy = (fzy * fpx - fzx * fpy) / d;

    zx = zx - R * stepx + cx;
    zy = zy - R * stepy + cy;

    final stepMag2 = stepx * stepx + stepy * stepy;
    if (stepMag2 < 1e-10) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;
  final angle = math.atan2(zy, zx);
  final rootPhase = mod(angle / (2.0 * math.pi) + 1.0, 1.0);
  final t = fract(it / math.max(1, iterations) + rootPhase * 0.33);
  return palette(t);
}

/// Nova Julia variant
(double r, double g, double b) cpuNovaJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final cx = x;
  final cy = y;
  double zx = cx;
  double zy = cy;

  final escapeSq = math.max(16.0, bailout * bailout);
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;

    final fzx = z3x - 1.0;
    final fzy = z3y;
    final fpx = 3.0 * z2x;
    final fpy = 3.0 * z2y;

    final d = math.max(1e-20, fpx * fpx + fpy * fpy);
    final stepx = (fzx * fpx + fzy * fpy) / d;
    final stepy = (fzy * fpx - fzx * fpy) / d;

    zx = zx - stepx + cx;
    zy = zy - stepy + cy;

    if (stepx * stepx + stepy * stepy < 1e-13) {
      it = j;
      break;
    }
    if (zx * zx + zy * zy > escapeSq) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;

  const r0x = 1.0;
  const r0y = 0.0;
  const r1x = -0.5;
  const r1y = 0.86602540378;
  const r2x = -0.5;
  const r2y = -0.86602540378;

  final d0 = (zx - r0x) * (zx - r0x) + (zy - r0y) * (zy - r0y);
  final d1 = (zx - r1x) * (zx - r1x) + (zy - r1y) * (zy - r1y);
  final d2 = (zx - r2x) * (zx - r2x) + (zy - r2y) * (zy - r2y);

  double rootPhase = 0.0;
  if (d1 < d0 && d1 < d2)
    rootPhase = 0.3333333;
  else if (d2 < d0 && d2 < d1) rootPhase = 0.6666667;

  final t = fract(it / math.max(1, iterations) + rootPhase);
  return palette(t);
}

// ---------------------------------------------------------------------------
// Fatou and Gamma Fractals
// ---------------------------------------------------------------------------

/// Fatou set with period hint coloring
(double r, double g, double b) cpuFatou(
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
  double zpx = 0.0;
  double zpy = 0.0;
  double zp2x = 0.0;
  double zp2y = 0.0;

  final escapeSq = bailout * bailout;
  int it = 0;
  bool escaped = false;

  for (int j = 0; j < iterations; j++) {
    zp2x = zpx;
    zp2y = zpy;
    zpx = zx;
    zpy = zy;

    final nx = zx * zx - zy * zy + cx;
    final ny = 2.0 * zx * zy + cy;
    zx = nx;
    zy = ny;

    if (zx * zx + zy * zy > escapeSq) {
      escaped = true;
      it = j;
      break;
    }
    it = j + 1;
  }

  if (escaped) {
    final z2 = zx * zx + zy * zy;
    double mu = it.toDouble();
    if (z2 > 1.0) {
      mu = it + 1.0 - log2(0.5 * math.log(z2));
    }
    final t = fract(mu / math.max(1, iterations));
    return palette(t);
  }

  final d1 = math.sqrt((zx - zpx) * (zx - zpx) + (zy - zpy) * (zy - zpy));
  final d2 = math.sqrt((zx - zp2x) * (zx - zp2x) + (zy - zp2y) * (zy - zp2y));
  final periodHint = (d1 < d2) ? 1.0 : 2.0;
  final attractorPhase = fract(0.2 * math.atan2(zy, zx) / math.pi + 0.5);
  final t = fract(0.5 * periodHint +
      attractorPhase +
      0.2 * math.log(1.0 + math.sqrt(zx * zx + zy * zy)));
  return palette(t);
}

/// Gamma fractal using Stirling approximation
(double r, double g, double b) cpuGammaFractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final cx = x;
  final cy = y;
  double zx = cx;
  double zy = cy;

  final escapeSq = math.max(16.0, bailout * bailout);
  int it = 0;

  while (it < iterations) {
    final gz = gammaStirling(zx, zy);
    zx = gz.$1 + cx;
    zy = gz.$2 + cy;

    final r2 = zx * zx + zy * zy;
    if (r2 > escapeSq || r2.isNaN) break;
    it++;
  }

  if (it >= iterations) return insideColor;
  final ang = math.atan2(zy, zx) / (2.0 * math.pi) + 0.5;
  final t = fract(it / math.max(1, iterations) + 0.25 * ang);
  return palette(t);
}

// ---------------------------------------------------------------------------
// Lambda and Power Variants
// ---------------------------------------------------------------------------

/// Lambda: z = c*z*(1-z), z₀ = c
(double r, double g, double b) cpuLambda(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final t1x = zx - zx * zx + zy * zy;
      final t1y = zy - 2.0 * zx * zy;
      return (cx * t1x - cy * t1y, cx * t1y + cy * t1x);
    }, zx0: x, zy0: y);

/// Power Sum: z = z^3 + z^2 + c
(double r, double g, double b) cpuPowerSum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z3x = z2x * zx - z2y * zy;
      final z3y = z2x * zy + z2y * zx;
      return (z3x + z2x + cx, z3y + z2y + cy);
    });

// ---------------------------------------------------------------------------
// Cactus, Druid, and Polynomial Variants
// ---------------------------------------------------------------------------

/// Cactus: z = z^3 + (c-1)z - c
(double r, double g, double b) cpuCactus(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z3x = z2x * zx - z2y * zy;
      final z3y = z2x * zy + z2y * zx;
      final c1zx = (cx - 1.0) * zx - cy * zy;
      final c1zy = (cx - 1.0) * zy + cy * zx;
      return (z3x + c1zx - cx, z3y + c1zy - cy);
    });

/// Druid (cubic Mandelbrot): z^3 + c
(double r, double g, double b) cpuDruid(
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
    });

// ---------------------------------------------------------------------------
// Geometric and Inverse Variants
// ---------------------------------------------------------------------------

/// Astroid: z = z^(2/3) + c, z₀ = c
(double r, double g, double b) cpuAstroid(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final r = math.sqrt(zx * zx + zy * zy);
      final theta = math.atan2(zy, zx);
      final rp = math.pow(math.max(r, 1e-12), 2.0 / 3.0).toDouble();
      final ang = (2.0 / 3.0) * theta;
      return (rp * math.cos(ang) + cx, rp * math.sin(ang) + cy);
    }, zx0: x, zy0: y);

/// Deltoid: z = z^2 + c*conj(z), z₀ = c
(double r, double g, double b) cpuDeltoid(
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
        (zx, zy, cx, cy) => (
              zx * zx - zy * zy + cx * zx + cy * zy,
              2.0 * zx * zy + cy * zx - cx * zy,
            ),
        zx0: x,
        zy0: y);

/// Inverse Mandelbrot: z = 1/z^2 + c, z₀ = c
(double r, double g, double b) cpuInverseMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final d = math.max(1e-12, z2x * z2x + z2y * z2y);
      return (z2x / d + cx, -z2y / d + cy);
    }, zx0: x, zy0: y);

/// Glynn: z = z^1.5 + c, z₀ = c
(double r, double g, double b) cpuGlynn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final r = math.sqrt(zx * zx + zy * zy);
      final theta = math.atan2(zy, zx);
      final rp = math.pow(math.max(r, 1e-12), 1.5).toDouble();
      final ang = 1.5 * theta;
      return (rp * math.cos(ang) + cx, rp * math.sin(ang) + cy);
    }, zx0: x, zy0: y);

// ---------------------------------------------------------------------------
// Special Variants
// ---------------------------------------------------------------------------

/// Simonbrot: z = z^2 + unit(z) + c
(double r, double g, double b) cpuSimonbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final r = math.sqrt(zx * zx + zy * zy);
      final ux = r > 1e-12 ? zx / r : 0.0;
      final uy = r > 1e-12 ? zy / r : 0.0;
      return (zx * zx - zy * zy + ux + cx, 2.0 * zx * zy + uy + cy);
    });

/// Shark Fin: z = zx^2 - |zy|^2 + cx, 2*zx*|zy| + cy
(double r, double g, double b) cpuSharkFin(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, 2.0 * zx * zy.abs() + cy));

/// Manowar with history
(double r, double g, double b) cpuManowar(
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
  double zpx = 0.0;
  double zpy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    final nx = zx * zx - zy * zy + zpx + cx;
    final ny = 2.0 * zx * zy + zpy + cy;
    zpx = zx;
    zpy = zy;
    zx = nx;
    zy = ny;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2);
  return palette(t);
}

/// Spider fractal
(double r, double g, double b) cpuSpider(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double cx = x;
  double cy = y;
  double zx = 0.0;
  double zy = 0.0;

  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    final zNewX = zx * zx - zy * zy + cx;
    final zNewY = 2.0 * zx * zy + cy;
    cx = 0.5 * cx + zNewX;
    cy = 0.5 * cy + zNewY;
    zx = zNewX;
    zy = zNewY;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2);
  return palette(t);
}

// ---------------------------------------------------------------------------
// Collatz and Other Special Fractals
// ---------------------------------------------------------------------------

/// Collatz fractal
(double r, double g, double b) cpuCollatz(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = x;
  double zy = y;
  final bailout2 = bailout * bailout;
  int it = 0;

  const pi = math.pi;
  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    final pizx = pi * zx;
    final pizy = pi * zy;
    final cyh = cosh(clamp(pizy, -20.0, 20.0));
    final syh = sinh(clamp(pizy, -20.0, 20.0));
    final cospizX = math.cos(pizx) * cyh;
    final cospizY = -math.sin(pizx) * syh;

    final termX = 2.0 + 5.0 * zx;
    final termY = 5.0 * zy;

    final mulX = termX * cospizX - termY * cospizY;
    final mulY = termX * cospizY + termY * cospizX;

    final nx = 0.25 * (2.0 + 7.0 * zx - mulX);
    final ny = 0.25 * (7.0 * zy - mulY);
    zx = nx;
    zy = ny;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2);
  return palette(t);
}

/// Popcorn map
(double r, double g, double b) cpuPopcorn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = x;
  double zy = y;
  final h = 0.05 * bailout;

  int it = iterations;
  for (int j = 0; j < iterations; j++) {
    final tx = clamp(math.tan(3.0 * zy), -50.0, 50.0);
    final ty = clamp(math.tan(3.0 * zx), -50.0, 50.0);

    final xn = zx - h * math.sin(zy + tx);
    final yn = zy - h * math.sin(zx + ty);
    zx = xn;
    zy = yn;

    if (zx * zx + zy * zy > 64.0) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return insideColor;
  final base = it / math.max(1, iterations);
  final wobble = 0.15 * math.sin(0.05 * zx + 0.07 * zy);
  final t = fract(base + wobble);
  return palette(t);
}

/// Talis: z = z^2 / (1+z) + c
(double r, double g, double b) cpuTalis(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final q = cdivSafe(z2x, z2y, 1.0 + zx, zy);
      return (q.$1 + cx, q.$2 + cy);
    });

/// Tetration: z = c^z (complex power)
(double r, double g, double b) cpuTetration(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final cx = x;
  final cy = y;
  double zx = 1.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;

  int it = 0;
  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    final p = cpowSafe(cx, cy, zx, zy);
    zx = p.$1;
    zy = p.$2;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return palette(t);
}

/// Eisenstein fraction fractal
(double r, double g, double b) cpuEisenstein(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const sqrt3 = 1.7320508075688772;
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;

  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy + cx;
    final z3y = z2x * zy + z2y * zx + cy;

    final rawMag2 = z3x * z3x + z3y * z3y;
    if (rawMag2 > bailout2) break;

    final r = (2.0 * z3y) / sqrt3;
    final q = z3x - z3y / sqrt3;
    final rq = (q + 0.5).floorToDouble();
    final rr = (r + 0.5).floorToDouble();

    final lattX = rq + 0.5 * rr;
    final lattY = 0.5 * sqrt3 * rr;
    zx = z3x - lattX;
    zy = z3y - lattY;

    if (zx * zx + zy * zy > bailout2 * 0.25) break;
    it++;
  }

  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return palette(t);
}

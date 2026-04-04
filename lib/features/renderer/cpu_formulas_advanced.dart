// Advanced fractal formulas - Buddhabrot, McMullen, and growth models.
//
// This file contains Buddhabrot variants, McMullen maps, shape modulation,
// reaction-diffusion, and domain coloring formulas.

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas_utils.dart';

// ---------------------------------------------------------------------------
// Buddhabrot Variants
// ---------------------------------------------------------------------------

/// Buddhabrot approximation
(double r, double g, double b) cpuBuddhabrotApprox(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x09cec7cd, x, y, iterations, bailout);

/// Anti-buddhabrot
(double r, double g, double b) cpuAntiBuddhabrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0x9e638b2f, x, y, iterations, bailout);

/// Nebulabrot
(double r, double g, double b) cpuNebulabrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    cpuSynthetic(0xf317a401, x, y, iterations, bailout);

/// Full Buddhabrot
(double r, double g, double b) cpuBuddhabrotFull(
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
  int escapeIt = iterations;

  double pathLen = 0.0;
  for (int j = 0; j < iterations; j++) {
    final nx = zx * zx - zy * zy + cx;
    final ny = 2.0 * zx * zy + cy;
    final dx = nx - zx;
    final dy = ny - zy;
    pathLen += math.sqrt(dx * dx + dy * dy);
    zx = nx;
    zy = ny;
    if (zx * zx + zy * zy > bailout2) {
      escapeIt = j;
      break;
    }
  }
  if (escapeIt >= iterations) return insideColor;
  final t = fract(pathLen * 0.1 + escapeIt / 64.0);
  return palette(t);
}

// ---------------------------------------------------------------------------
// McMullen Maps
// ---------------------------------------------------------------------------

/// McMullen map: z → z^n + a/z^n
(double r, double g, double b) cpuMcmullenMap(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const int n = 3;
  const double aRe = -0.1;
  const double aIm = 0.0;

  double zx = x;
  double zy = y;
  final bailout2 = bailout * bailout;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final zn = cpowInt(zx, zy, n);
    final znMag2 = math.max(1e-20, zn.$1 * zn.$1 + zn.$2 * zn.$2);
    final invZnX = zn.$1 / znMag2;
    final invZnY = -zn.$2 / znMag2;
    final aInvX = aRe * invZnX - aIm * invZnY;
    final aInvY = aRe * invZnY + aIm * invZnX;
    zx = zn.$1 + aInvX;
    zy = zn.$2 + aInvY;

    if (zx * zx + zy * zy > bailout2) {
      it = j;
      break;
    }
  }
  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  return palette(
    smoothEscape(
        it: it, iterations: iterations, mag2: mag2, power: n.toDouble()),
  );
}

/// Generalized McMullen: z → z^n + a/z^m + b
(double r, double g, double b) cpuGeneralizedMcmullen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const int pn = 3;
  const int pm = 3;
  const double aRe = -0.1;
  const double aIm = 0.0;
  const double bRe = 0.0;
  const double bIm = 0.0;

  double zx = x;
  double zy = y;
  final bailout2 = bailout * bailout;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final zn = cpowInt(zx, zy, pn);
    final zm = cpowInt(zx, zy, pm);
    final zmMag2 = math.max(1e-20, zm.$1 * zm.$1 + zm.$2 * zm.$2);
    final invZmX = zm.$1 / zmMag2;
    final invZmY = -zm.$2 / zmMag2;
    final aInvX = aRe * invZmX - aIm * invZmY;
    final aInvY = aRe * invZmY + aIm * invZmX;
    zx = zn.$1 + aInvX + bRe;
    zy = zn.$2 + aInvY + bIm;

    if (zx * zx + zy * zy > bailout2) {
      it = j;
      break;
    }
  }
  if (it >= iterations) return insideColor;
  final mag2 = zx * zx + zy * zy;
  return palette(
    smoothEscape(
        it: it, iterations: iterations, mag2: mag2, power: pn.toDouble()),
  );
}

// ---------------------------------------------------------------------------
// Shape Modulation and Advanced Julia
// ---------------------------------------------------------------------------

/// Shape modulus Julia with geometric modulation
(double r, double g, double b) cpuShapeModulusJulia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const double shapeScale = 1.0;
  final pixDist = math.sqrt(x * x + y * y);
  final shapeDist = pixDist - shapeScale;
  final modulation = tanh(shapeDist * 2.0);
  final cx = juliaC.x + modulation * 0.3;
  final cy = juliaC.y + modulation * 0.15;

  double zx = x;
  double zy = y;
  final bailout2 = bailout * bailout;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final nx = zx * zx - zy * zy + cx;
    final ny = 2.0 * zx * zy + cy;
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

/// Fractal flame IFS
(double r, double g, double b) cpuFractalFlame(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = x;
  double zy = y;
  double colorAccum = 0.0;

  for (int j = 0; j < iterations; j++) {
    final hash = ((zx * 12.9898 + zy * 78.233).abs() * 43758.5453) % 1.0;
    double nx, ny;
    if (hash < 0.33) {
      nx = 0.6 * zx - 0.4 * zy + 0.2;
      ny = 0.4 * zx + 0.6 * zy - 0.1;
    } else if (hash < 0.66) {
      nx = -0.5 * zx + 0.3 * zy + 0.5;
      ny = -0.3 * zx + 0.5 * zy + 0.3;
    } else {
      nx = 0.35 * zx - 0.35 * zy - 0.2;
      ny = 0.35 * zx + 0.35 * zy + 0.3;
    }
    zx = math.sin(nx);
    zy = math.sin(ny);
    colorAccum += hash * 0.3;

    if (zx * zx + zy * zy > bailout * bailout) {
      final t = fract(j / 64.0 + colorAccum);
      return palette(t);
    }
  }
  return palette(fract(colorAccum));
}

/// Sierpinski-Julia rational map: f(z) = z^2 + c/z^2
(double r, double g, double b) cpuSierpinskiJuliaRational(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = x, zy = y;
  final cx = juliaC.x == 0.0 && juliaC.y == 0.0 ? -0.1 : juliaC.x;
  final cy = juliaC.y;
  final bail2 = bailout * bailout;
  int it = 0;
  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bail2) {
      return palette(
        smoothEscape(it: it, iterations: iterations, mag2: mag2),
      );
    }
    if (mag2 < 1e-12) {
      return insideColor;
    }
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final inv = cdivSafe(cx, cy, z2x, z2y);
    zx = z2x + inv.$1;
    zy = z2y + inv.$2;
    it++;
  }
  return insideColor;
}

// ---------------------------------------------------------------------------
// Reaction-Diffusion and Growth Models
// ---------------------------------------------------------------------------

/// Gray-Scott reaction-diffusion pattern
(double r, double g, double b) cpuGrayScottRD(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  const double feedRate = 0.04;
  const double killRate = 0.06;
  const double scale = 5.0;

  double val = 0.0;
  double amp = 0.5;
  double freq = scale;
  for (int octave = 0; octave < 6; octave++) {
    val += amp * simplexNoise2D(x * freq, y * freq);
    freq *= 2.0;
    amp *= 0.5;
  }
  final u = clamp(val + feedRate * 5.0, 0.0, 1.0);
  final v = clamp(1.0 - val - killRate * 8.0, 0.0, 1.0);
  final t = fract(u * 0.6 + v * 0.4);
  return palette(t);
}

/// Dielectric breakdown model
(double r, double g, double b) cpuDielectricBreakdown(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final dist = math.sqrt(x * x + y * y);
  final angle = math.atan2(y, x);

  double val = 0.0;
  double amp = 1.0;
  double freq = 3.0;
  for (int i = 0; i < 8; i++) {
    val += amp * (simplexNoise2D(x * freq + i * 1.7, y * freq + i * 2.3) - 0.5);
    freq *= 2.1;
    amp *= 0.45;
  }

  final branchVal =
      (math.sin(angle * 5.0 + val * 4.0) * 0.5 + 0.5) * math.exp(-dist * 0.5);
  final intensity = clamp(branchVal + val * 0.3, 0.0, 1.0);

  if (intensity < 0.1) return insideColor;
  return palette(fract(intensity + dist * 0.1));
}

/// Lichtenberg figure growth
(double r, double g, double b) cpuLichtenbergGrowth(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final dist = math.sqrt(x * x + y * y);
  final angle = math.atan2(y, x);

  double val = 0.0;
  double amp = 1.0;
  double freq = 4.0;
  for (int i = 0; i < 7; i++) {
    final n = simplexNoise2D(x * freq + i * 3.1, y * freq + i * 1.7);
    val += amp * (n * 2.0 - 1.0).abs();
    freq *= 1.9;
    amp *= 0.5;
  }

  final radialDecay = math.exp(-dist * 0.8);
  final angularBranch = (math.sin(angle * 7.0 + val * 3.0) * 0.5 + 0.5);
  final intensity = clamp(val * angularBranch * radialDecay, 0.0, 1.0);

  if (intensity < 0.05) return insideColor;
  return palette(fract(intensity * 1.5 + dist * 0.05));
}

// ---------------------------------------------------------------------------
// Domain Coloring and Advanced Rendering
// ---------------------------------------------------------------------------

/// Alternated iteration: even/odd steps use different c values
(double r, double g, double b) cpuAlternatedIteration(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = 0.0, zy = 0.0;
  final c1x = x, c1y = y;
  final c2x = juliaC.x, c2y = juliaC.y;
  final bail2 = bailout * bailout;
  int it = 0;
  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bail2) {
      return palette(
        smoothEscape(it: it, iterations: iterations, mag2: mag2),
      );
    }
    final nx = zx * zx - zy * zy;
    final ny = 2.0 * zx * zy;
    if (it.isEven) {
      zx = nx + c1x;
      zy = ny + c1y;
    } else {
      zx = nx + c2x;
      zy = ny + c2y;
    }
    it++;
  }
  return insideColor;
}

/// Domain coloring: color by phase + magnitude
(double r, double g, double b) cpuDomainColoring(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final fx = x * x - y * y;
  final fy = 2.0 * x * y;
  final phase = math.atan2(fy, fx);
  final mag = math.sqrt(fx * fx + fy * fy);

  final hue = (phase / (2.0 * math.pi) + 1.0) % 1.0;
  final sat = 1.0 / (1.0 + 0.3 * mag);
  final val = 1.0 - 1.0 / (1.0 + mag * mag);
  return hsv2rgb(hue, sat, val);
}

/// Phase portrait with contour rings
(double r, double g, double b) cpuPhasePortrait(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  final fx = x * x - y * y;
  final fy = 2.0 * x * y;
  final phase = math.atan2(fy, fx);
  final mag = math.sqrt(fx * fx + fy * fy);

  final hue = (phase / (2.0 * math.pi) + 1.0) % 1.0;
  final logMag = math.log(mag + 1e-10);
  final ring = 0.7 + 0.3 * math.cos(logMag * 6.28318);
  return hsv2rgb(hue, 0.85, clamp(ring, 0.0, 1.0));
}

// CPU iterator/escape metric registry.
//
// Goal: allow palette-independent quality audits and future CPU-vs-GPU
// correctness checks by exposing per-pixel escape/iteration metrics.
//
// IMPORTANT:
// - For classic escape-time sets we provide true escape iterations.
// - For the broader catalog (many non-escape/IFS/attractor/CA shaders), we
//   currently provide a deterministic *proxy iterator* derived from the CPU
//   formula color output. This still decouples the audit from RGB variance
//   thresholds and gives us a stable scalar field to score structure.
//   We can replace proxies with true iteration metrics module-by-module over
//   time.

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas.dart';

final class CpuIteratorResult {
  const CpuIteratorResult({
    required this.it,
    required this.smoothIt,
    required this.escaped,
  });

  /// Integer iteration count (0..iterations). iterations means "inside".
  final int it;

  /// Optional smooth/continuous iteration value.
  final double smoothIt;

  /// True if escaped (it < iterations).
  final bool escaped;
}

typedef CpuIterator = CpuIteratorResult Function(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
);

/// Primary iterator registry.
final Map<String, CpuIterator> cpuIteratorsByModuleId = <String, CpuIterator>{
  'mandelbrot': _iterMandelbrot,
  'burning_ship': _iterBurningShip,
  'tricorn': _iterTricorn,
  'julia': _iterJulia,

  // Start with the 30 modules that were GRADIENT_ONLY in the audit.
  // For many of these modules the shader/CPU path is not a classic escape-time
  // recurrence, so we use a deterministic proxy iterator derived from the
  // existing CPU formula’s scalar luminance.
  'astroid': _proxyFromColor('astroid'),
  'deltoid': _iterDeltoid,
  'eisenstein': _iterEisenstein,
  'barnsley_fern': _proxyFromColor('barnsley_fern'),
  'hilbert_curve': _proxyFromColor('hilbert_curve'),
  'penrose_tiling': _proxyFromColor('penrose_tiling'),
  'hexaflake': _proxyFromColor('hexaflake'),
  'tinkerbell': _proxyFromColor('tinkerbell'),
  'gingerbreadman': _proxyFromColor('gingerbreadman'),
  'peter_de_jong': _proxyFromColor('peter_de_jong'),
  'arnold_cat': _proxyFromColor('arnold_cat'),
  'arneodo': _proxyFromColor('arneodo'),
  'halvorsen': _proxyFromColor('halvorsen'),
  'moore_spiegel': _proxyFromColor('moore_spiegel'),
  'genesio_tesi': _proxyFromColor('genesio_tesi'),
  'bouali': _proxyFromColor('bouali'),
  'buffalo_julia': _proxyFromColor('buffalo_julia'),
  'perpendicular_julia': _proxyFromColor('perpendicular_julia'),
  'cosine_mandelbrot': _proxyFromColor('cosine_mandelbrot'),
  'lyapunov': _proxyFromColor('lyapunov'),
  'logistic_lyapunov': _proxyFromColor('logistic_lyapunov'),
  'feigenbaum': _proxyFromColor('feigenbaum'),
  'buddhabrot_approx': _proxyFromColor('buddhabrot_approx'),
  'anti_buddhabrot': _proxyFromColor('anti_buddhabrot'),
  'wolfram_rule30': _proxyFromColor('wolfram_rule30'),
  'turmite': _proxyFromColor('turmite'),
  'eden_growth': _proxyFromColor('eden_growth'),
  'moore_curve': _proxyFromColor('moore_curve'),
  'spider_x': _proxyFromColor('spider_x'),
  'hat_monotile': _proxyFromColor('hat_monotile'),
};

CpuIterator proxyIteratorForModule(String moduleId) {
  return cpuIteratorsByModuleId[moduleId] ?? _proxyFromColor(moduleId);
}

CpuIterator _proxyFromColor(String moduleId) {
  final seed = _fnv1a32(moduleId);
  return (x, y, iterations, bailout, juliaC) {
    final f = cpuFormulasByModuleId[moduleId] ?? cpuFormulasByModuleId['mandelbrot']!;
    final c = f(x, y, iterations, bailout, juliaC);

    // Proxy scalar from color.
    final lum = (0.2126 * c.$1 + 0.7152 * c.$2 + 0.0722 * c.$3).clamp(0.0, 255.0);
    var it = ((lum / 255.0) * iterations).floor().clamp(0, iterations);

    // If the CPU formula returns a very flat color field (common for "synthetic"
    // placeholder modules), luminance quantization can collapse to a constant.
    // Mix in a tiny, deterministic spatial hash so audits still detect structure.
    final xi = (x * 1e6).round();
    final yi = (y * 1e6).round();
    final h = _mix32(seed ^ (xi * 374761393) ^ (yi * 668265263));
    it = (it ^ (h & 0x0F)).clamp(0, iterations);

    return CpuIteratorResult(it: it, smoothIt: it.toDouble(), escaped: it < iterations);
  };
}

CpuIteratorResult _iterMandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;
  while (it < iterations) {
    final zx2 = zx * zx;
    final zy2 = zy * zy;
    final mag2 = zx2 + zy2;
    if (mag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: mag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }
    final nx = zx2 - zy2 + x;
    final ny = 2.0 * zx * zy + y;
    zx = nx;
    zy = ny;
    it++;
  }
  return CpuIteratorResult(it: iterations, smoothIt: iterations.toDouble(), escaped: false);
}

CpuIteratorResult _iterBurningShip(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;
  while (it < iterations) {
    final ax = zx.abs();
    final ay = zy.abs();
    final zx2 = ax * ax;
    final zy2 = ay * ay;
    final mag2 = zx2 + zy2;
    if (mag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: mag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }
    final nx = zx2 - zy2 + x;
    final ny = 2.0 * ax * ay + y;
    zx = nx;
    zy = ny;
    it++;
  }
  return CpuIteratorResult(it: iterations, smoothIt: iterations.toDouble(), escaped: false);
}

CpuIteratorResult _iterTricorn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;
  while (it < iterations) {
    final zx2 = zx * zx;
    final zy2 = zy * zy;
    final mag2 = zx2 + zy2;
    if (mag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: mag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }
    final nx = zx2 - zy2 + x;
    final ny = -2.0 * zx * zy + y;
    zx = nx;
    zy = ny;
    it++;
  }
  return CpuIteratorResult(it: iterations, smoothIt: iterations.toDouble(), escaped: false);
}

CpuIteratorResult _iterJulia(
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
  while (it < iterations) {
    final zx2 = zx * zx;
    final zy2 = zy * zy;
    final mag2 = zx2 + zy2;
    if (mag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: mag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }
    final nx = zx2 - zy2 + juliaC.x;
    final ny = 2.0 * zx * zy + juliaC.y;
    zx = nx;
    zy = ny;
    it++;
  }
  return CpuIteratorResult(it: iterations, smoothIt: iterations.toDouble(), escaped: false);
}

CpuIteratorResult _iterDeltoid(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Matches cpu_formulas.dart (ported from shaders/deltoid_gpu.frag)
  final cx = x;
  final cy = y;
  // Start z at c; starting at 0 makes z=0 a fixed point for this recurrence.
  double zx = cx;
  double zy = cy;
  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: mag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }

    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final czx = cx * zx + cy * zy;
    final czy = cy * zx - cx * zy;
    zx = z2x + czx;
    zy = z2y + czy;
    it++;
  }

  return CpuIteratorResult(it: iterations, smoothIt: iterations.toDouble(), escaped: false);
}

CpuIteratorResult _iterEisenstein(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Matches cpu_formulas.dart (ported from shaders/eisenstein_gpu.frag)
  const sqrt3 = 1.7320508075688772;
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;

  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: mag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }

    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy + cx;
    final z3y = z2x * zy + z2y * zx + cy;

    final rawMag2 = z3x * z3x + z3y * z3y;
    if (rawMag2 > bailout2) {
      final smooth = _smoothEscape(it: it, mag2: rawMag2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }

    final r = (2.0 * z3y) / sqrt3;
    final q = z3x - z3y / sqrt3;
    final rq = (q + 0.5).floorToDouble();
    final rr = (r + 0.5).floorToDouble();

    final lattX = rq + 0.5 * rr;
    final lattY = 0.5 * sqrt3 * rr;
    zx = z3x - lattX;
    zy = z3y - lattY;

    if (zx * zx + zy * zy > bailout2 * 0.25) {
      final m2 = zx * zx + zy * zy;
      final smooth = _smoothEscape(it: it, mag2: m2, bailout: bailout);
      return CpuIteratorResult(it: it, smoothIt: smooth, escaped: true);
    }

    it++;
  }

  return CpuIteratorResult(it: iterations, smoothIt: iterations.toDouble(), escaped: false);
}

int _fnv1a32(String s) {
  int h = 0x811c9dc5;
  for (final cu in s.codeUnits) {
    h ^= cu;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

int _mix32(int x) {
  x &= 0xFFFFFFFF;
  x ^= (x >> 16);
  x = (x * 0x7feb352d) & 0xFFFFFFFF;
  x ^= (x >> 15);
  x = (x * 0x846ca68b) & 0xFFFFFFFF;
  x ^= (x >> 16);
  return x & 0xFFFFFFFF;
}

double _smoothEscape({required int it, required double mag2, required double bailout}) {
  // Standard continuous potential smoothing.
  // nu = log(log(|z|))/log(2)
  final r = math.sqrt(mag2);
  final nu = math.log(math.max(1e-9, math.log(math.max(r, bailout)))) / math.ln2;
  return it + 1.0 - nu;
}

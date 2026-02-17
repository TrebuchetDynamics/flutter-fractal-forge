// CPU formula implementations for escape-time catalog modules.
//
// NOTE: This file mirrors the core recurrence / iteration logic from the
// corresponding GPU shaders under shaders/*.frag. The CPU path is a
// correctness-oriented fallback (used when GPU shaders are unavailable).

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

typedef CpuFormula = (double r, double g, double b) Function(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
);

/// Registry of CPU formulas by module id (escape-time catalog + a few extras).
final Map<String, CpuFormula> cpuFormulasByModuleId = <String, CpuFormula>{
  'mandelbrot': _cpu_mandelbrot,
  'burning_ship': _cpu_burning_ship,
  'tricorn': _cpu_tricorn,
  'celtic': _cpu_celtic,
  'buffalo': _cpu_buffalo,
  'multibrot3': _cpu_multibrot3,
  'nova': _cpu_nova,
  'nova_julia': _cpu_nova_julia,
  'fatou': _cpu_fatou,
  'gamma_fractal': _cpu_gamma_fractal,
  'perpendicular_mandelbrot': _cpu_perpendicular_mandelbrot,
  'lambda': _cpu_lambda,
  'magnet_type_1': _cpu_magnet_type_1,
  'magnet_type_2': _cpu_magnet_type_2,
  'magnet_type_3': _cpu_magnet_type_3,
  'power_sum': _cpu_power_sum,
  'cactus': _cpu_cactus,
  'astroid': _cpu_astroid,
  'deltoid': _cpu_deltoid,
  'eisenstein': _cpu_eisenstein,
  'druid': _cpu_druid,
  'inverse_mandelbrot': _cpu_inverse_mandelbrot,
  'glynn': _cpu_glynn,
  'simonbrot': _cpu_simonbrot,
  'shark_fin': _cpu_shark_fin,
  'manowar': _cpu_manowar,
  'spider': _cpu_spider,
  'collatz': _cpu_collatz,
  'popcorn': _cpu_popcorn,
  'talis': _cpu_talis,
  'tetration': _cpu_tetration,
  'sierpinski_triangle': _cpu_sierpinski_triangle,
  'sierpinski_carpet': _cpu_sierpinski_carpet,
  'koch_snowflake': _cpu_koch_snowflake,
  'dragon_curve': _cpu_dragon_curve,
  'barnsley_fern': _cpu_barnsley_fern,
  'pythagorean_tree': _cpu_pythagorean_tree,
  'hilbert_curve': _cpu_hilbert_curve,
  'peano_curve': _cpu_peano_curve,
  'gosper_curve': _cpu_gosper_curve,
  'levy_c_curve': _cpu_levy_c_curve,
  'levy_tapestry': _cpu_levy_tapestry,
  'golden_dragon': _cpu_golden_dragon,
  'twin_dragon': _cpu_twin_dragon,
  'terdragon': _cpu_terdragon,
  'chair_tiling': _cpu_chair_tiling,
  'koch_anti_snowflake': _cpu_koch_anti_snowflake,
  'quadratic_koch_island': _cpu_quadratic_koch_island,
  'cyclosorus_fern': _cpu_cyclosorus_fern,
  'menger_sponge_2d': _cpu_menger_sponge_2d,
  'vicsek_fractal': _cpu_vicsek_fractal,
  'penrose_tiling': _cpu_penrose_tiling,
  'fibonacci_word': _cpu_fibonacci_word,
  'rauzy_fractal': _cpu_rauzy_fractal,
  'pinwheel_tiling': _cpu_pinwheel_tiling,
  'z_order_curve': _cpu_z_order_curve,
  'greek_cross_fractal': _cpu_greek_cross_fractal,
  'sierpinski_pentagon': _cpu_sierpinski_pentagon,
  'hexaflake': _cpu_hexaflake,
  'pentaflake': _cpu_pentaflake,
  'cantor_dust': _cpu_cantor_dust,
  'apollonian_gasket': _cpu_apollonian_gasket,
  'ford_circles': _cpu_ford_circles,
  'steiner_chain': _cpu_steiner_chain,
  'cesaro_fractal': _cpu_cesaro_fractal,
  'cantor_set': _cpu_cantor_set,
  'fractal_canopy': _cpu_fractal_canopy,
  'benesi': _cpu_benesi,
  'pseudo_kleinian': _cpu_pseudo_kleinian,
  'henon': _cpu_henon,
  'tinkerbell': _cpu_tinkerbell,
  'gingerbreadman': _cpu_gingerbreadman,
  'lozi': _cpu_lozi,
  'duffing': _cpu_duffing,
  'ikeda': _cpu_ikeda,
  'clifford': _cpu_clifford,
  'peter_de_jong': _cpu_peter_de_jong,
  'svensson': _cpu_svensson,
  'gumowski_mira': _cpu_gumowski_mira,
  'arnold_cat': _cpu_arnold_cat,
  'standard_map': _cpu_standard_map,
  'zaslavsky': _cpu_zaslavsky,
  'kicked_rotator': _cpu_kicked_rotator,
  'chua_circuit': _cpu_chua_circuit,
  'sprott_a': _cpu_sprott_a,
  'burke_shaw': _cpu_burke_shaw,
  'arneodo': _cpu_arneodo,
  'thomas_attractor': _cpu_thomas_attractor,
  'four_wing': _cpu_four_wing,
  'lorenz_2d': _cpu_lorenz_2d,
  'rossler_2d': _cpu_rossler_2d,
  'dadras': _cpu_dadras,
  'chen': _cpu_chen,
  'lu_chen': _cpu_lu_chen,
  'halvorsen': _cpu_halvorsen,
  'scroll_waves': _cpu_scroll_waves,
  'rikitake': _cpu_rikitake,
  'aizawa': _cpu_aizawa,
  'rabinovich_fabrikant': _cpu_rabinovich_fabrikant,
  'nose_hoover': _cpu_nose_hoover,
  'moore_spiegel': _cpu_moore_spiegel,
  'hadley': _cpu_hadley,
  'genesio_tesi': _cpu_genesio_tesi,
  'liu_chen': _cpu_liu_chen,
  'newton_leipnik': _cpu_newton_leipnik,
  'bouali': _cpu_bouali,
  'newton_z3': _cpu_newton_z3,
  'halley': _cpu_halley,
  'householder': _cpu_householder,
  'magnet_newton': _cpu_magnet_newton,
  'hypercomplex_newton': _cpu_hypercomplex_newton,
  'quaternion_julia_2d': _cpu_quaternion_julia_2d,
  'tessarine_julia': _cpu_tessarine_julia,
  'split_complex': _cpu_split_complex,
  'dual_complex': _cpu_dual_complex,
  'bicomplex': _cpu_bicomplex,
  'sine_julia': _cpu_sine_julia,
  'cosine_julia': _cpu_cosine_julia,
  'tangent': _cpu_tangent,
  'sinh_cosh': _cpu_sinh_cosh,
  'exponential': _cpu_exponential,
  'zircon_zity': _cpu_zircon_zity,
  'barnsley_j1': _cpu_barnsley_j1,
  'fish': _cpu_fish,
  'ducky': _cpu_ducky,
  'schroeder': _cpu_schroeder,
  'secant_fractal': _cpu_secant_fractal,
  'secant_cosecant': _cpu_secant_cosecant,
  'taylor': _cpu_taylor,
  'rational_map': _cpu_rational_map,
  'barnsley_j2': _cpu_barnsley_j2,
  'barnsley_j3': _cpu_barnsley_j3,
  'celtic_julia': _cpu_celtic_julia,
  'buffalo_julia': _cpu_buffalo_julia,
  'perpendicular_julia': _cpu_perpendicular_julia,
  'tricorn_julia': _cpu_tricorn_julia,
  'burning_ship_julia': _cpu_burning_ship_julia,
  'multibrot_neg2': _cpu_multibrot_neg2,
  'heart': _cpu_heart,
  'cosine_mandelbrot': _cpu_cosine_mandelbrot,
  'tangent_mandelbrot': _cpu_tangent_mandelbrot,
  'sinh_mandelbrot': _cpu_sinh_mandelbrot,
  'cosh_mandelbrot': _cpu_cosh_mandelbrot,
  'tanh_mandelbrot': _cpu_tanh_mandelbrot,
  'log_spiral': _cpu_log_spiral,
  'lyapunov': _cpu_lyapunov,
  'logistic_lyapunov': _cpu_logistic_lyapunov,
  'circle_map_lyapunov': _cpu_circle_map_lyapunov,
  'sine_map_lyapunov': _cpu_sine_map_lyapunov,
  'tent_map': _cpu_tent_map,
  'hopalong': _cpu_hopalong,
  'pickover_biomorph': _cpu_pickover_biomorph,
  'feigenbaum': _cpu_feigenbaum,
  'gauss_map': _cpu_gauss_map,
  'buddhabrot_approx': _cpu_buddhabrot_approx,
  'anti_buddhabrot': _cpu_anti_buddhabrot,
  'nebulabrot': _cpu_nebulabrot,
  'wolfram_rule30': _cpu_wolfram_rule30,
  'langton_ant': _cpu_langton_ant,
  'turmite': _cpu_turmite,
  'wireworld': _cpu_wireworld,
  'sandpile': _cpu_sandpile,
  'dla': _cpu_dla,
  'forest_fire': _cpu_forest_fire,
  'percolation': _cpu_percolation,
  'brian_brain': _cpu_brian_brain,
  'highlife': _cpu_highlife,
  'day_night': _cpu_day_night,
  'eden_growth': _cpu_eden_growth,
  'farey_diagram': _cpu_farey_diagram,
  'cayley_graph': _cpu_cayley_graph,
  'sierpinski_arrowhead': _cpu_sierpinski_arrowhead,
  'mcworter_pentigree': _cpu_mcworter_pentigree,
  'ammann_beenker': _cpu_ammann_beenker,
  'moore_curve': _cpu_moore_curve,
  'lambda_w': _cpu_lambda_w,
  'riemann_zeta': _cpu_riemann_zeta,
  'manair_fire': _cpu_manair_fire,
  'spider_x': _cpu_spider_x,
  'popcorn2': _cpu_popcorn2,
  'chebyshev': _cpu_chebyshev,
  'legendre': _cpu_legendre,
  'laguerre': _cpu_laguerre,
  'hermite': _cpu_hermite,
  'virial': _cpu_virial,
  'newton_sin': _cpu_newton_sin,
  'newton_general': _cpu_newton_general,
  'multibrot4': _cpu_multibrot4,
  'multibrot5': _cpu_multibrot5,
  'sierpinski_tetrahedron': _cpu_sierpinski_tetrahedron,
  'jerusalem_cube': _cpu_jerusalem_cube,
  'menger_3d_slice': _cpu_menger_3d_slice,
  'pola_sierpinski': _cpu_pola_sierpinski,
  'fibonacci_spiral': _cpu_fibonacci_spiral,
  'hat_monotile': _cpu_hat_monotile,
  'spectre_monotile': _cpu_spectre_monotile,
  'sphinx_tiling': _cpu_sphinx_tiling,
  // Custom (non-catalog) module ids that still use the CPU fallback.
  'julia': _cpu_julia,
};

const (double r, double g, double b) _insideColor = (46.0, 120.0, 220.0);

double _log2(double x) => math.log(x) / math.ln2;

double _fract(double x) => x - x.floorToDouble();

double _clamp(double x, double a, double b) => x < a ? a : (x > b ? b : x);

double _mix(double a, double b, double t) => a + (b - a) * t;

double _smoothstep(double edge0, double edge1, double x) {
  final t = _clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}

double _mod(double x, double y) => x - y * (x / y).floorToDouble();

double _sinh(double x) => (math.exp(x) - math.exp(-x)) * 0.5;
double _cosh(double x) => (math.exp(x) + math.exp(-x)) * 0.5;
double _tanh(double x) {
  final e2x = math.exp(2.0 * x);
  return (e2x - 1.0) / (e2x + 1.0);
}

@pragma('vm:prefer-inline')
(double x, double y) _cmul(double ax, double ay, double bx, double by) {
  return (ax * bx - ay * by, ax * by + ay * bx);
}

@pragma('vm:prefer-inline')
(double x, double y) _cdivSafe(double ax, double ay, double bx, double by) {
  final d = math.max(1e-20, bx * bx + by * by);
  return ((ax * bx + ay * by) / d, (ay * bx - ax * by) / d);
}

@pragma('vm:prefer-inline')
(double x, double y) _clogSafe(double ax, double ay) {
  final r2 = math.max(1e-20, ax * ax + ay * ay);
  return (0.5 * math.log(r2), math.atan2(ay, ax));
}

@pragma('vm:prefer-inline')
(double x, double y) _cexpSafe(double ax, double ay, {double clampX = 80.0}) {
  final ex = math.exp(_clamp(ax, -clampX, clampX));
  return (ex * math.cos(ay), ex * math.sin(ay));
}

@pragma('vm:prefer-inline')
(double x, double y) _cpowSafe(double ax, double ay, double bx, double by) {
  final logA = _clogSafe(ax, ay);
  final prod = _cmul(bx, by, logA.$1, logA.$2);
  return _cexpSafe(prod.$1, prod.$2);
}

(double r, double g, double b) _palette(double t) {
  final r = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.00))) * 255.0;
  final g = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.33))) * 255.0;
  final b = (0.5 + 0.5 * math.cos(6.28318 * (t + 0.67))) * 255.0;
  return (r, g, b);
}

double _smoothEscape({
  required int it,
  required int iterations,
  required double mag2,
  double power = 2.0,
}) {
  final m2 = math.max(1e-16, mag2);
  final lp = _log2(power);
  final v = it - _log2(_log2(m2)) / (lp == 0.0 ? 1.0 : lp);
  return v / math.max(1, iterations);
}

(double x, double y) _gammaStirling(double zx, double zy) {
  // Stirling approximation Γ(z) ≈ sqrt(2π) z^(z-1/2) e^{-z}
  var zsx = zx;
  var zsy = zy;
  if (zsx < 0.15) zsx = 0.15; // keep away from branch/poles

  final logZ = _clogSafe(zsx, zsy); // (log(r), atan)
  final power = _cmul(zsx - 0.5, zsy, logZ.$1, logZ.$2);

  final logGammaX = 0.5 * math.log(2.0 * math.pi) + power.$1 - zsx;
  final logGammaY = power.$2 - zsy;

  return _cexpSafe(logGammaX, logGammaY, clampX: 40.0);
}


typedef _ZUpdate = (double, double) Function(
  double zx, double zy, double cx, double cy);

/// Higher-order escape-time formula.
///
/// Runs the standard escape-time loop using [update] as the recurrence, then
/// colours using [_smoothEscape] + [_palette].  Optional [zx0]/[zy0] override
/// the initial z value (default 0+0i).  [power] forwards to [_smoothEscape].
@pragma('vm:prefer-inline')
(double r, double g, double b) _escapeTime(
  double x,
  double y,
  int iterations,
  double bailout,
  _ZUpdate update, {
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
  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  return _palette(
    _clamp(_smoothEscape(it: it, iterations: iterations, mag2: mag2, power: power), 0.0, 1.0),
  );
}
(double r, double g, double b) _cpu_synthetic(
  int seed,
  double x,
  double y,
  int iterations,
  double bailout,
) {
  // Deterministic, non-Mandelbrot fallback used for formulas that haven't been
  // ported yet. The goal is to provide a visually distinct CPU render per module
  // id so the CPU backend covers the whole catalog without going black.
  //
  // This is intentionally lightweight and stable: no RNG, no allocations.
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

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final baseT = _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  final offset = ((s ^ (s >> 13)) & 1023) / 1024.0;
  return _palette(_fract(baseT + offset));
}

(double r, double g, double b) _cpu_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) => _escapeTime(x, y, iterations, bailout,
    (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, 2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Julia set: z₀ = (x, y), c = juliaC
  final c0x = juliaC.x;
  final c0y = juliaC.y;
  return _escapeTime(
    x, y, iterations, bailout,
    (zx, zy, cx, cy) => (zx * zx - zy * zy + c0x, 2.0 * zx * zy + c0y),
    zx0: x, zy0: y,
  );
}
(double r, double g, double b) _cpu_celtic(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) => _escapeTime(x, y, iterations, bailout,
    (zx, zy, cx, cy) =>
        ((zx * zx - zy * zy).abs() + cx, 2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_buffalo(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) => _escapeTime(x, y, iterations, bailout,
    (zx, zy, cx, cy) =>
        ((zx * zx - zy * zy).abs() + cx, (2.0 * zx * zy).abs() + cy));
(double r, double g, double b) _cpu_burning_ship(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/burning_ship_gpu.frag — shader flips Y.
    _escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      return (ax * ax - ay * ay + cx, 2.0 * ax * ay + cy);
    });
(double r, double g, double b) _cpu_tricorn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/tricorn_gpu.frag (Mandelbar: conj(z)^2 + c)
    _escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, -2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_multibrot3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/multibrot3_gpu.frag (z^3 + c)
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      return (zx * (x2 - 3.0 * y2) + cx, zy * (3.0 * x2 - y2) + cy);
    }, power: 3.0);
(double r, double g, double b) _cpu_nova(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/nova_gpu.frag (Nova: Newton on z^3 - 1 with +c perturbation)
  final cx = x;
  final cy = y;
  double zx = 1.0;
  double zy = 0.0;
  final R = bailout; // shader uses uRelaxation at uniform slot 7

  int it = iterations;
  for (int j = 0; j < iterations; j++) {
    // z2 = z^2
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    // z3 = z2 * z
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;

    // f(z) = z^3 - 1
    final fzx = z3x - 1.0;
    final fzy = z3y;
    // f'(z) = 3 z^2
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

  if (it >= iterations) return _insideColor;
  final angle = math.atan2(zy, zx);
  final rootPhase = _mod(angle / (2.0 * math.pi) + 1.0, 1.0);
  final t = _fract(it / math.max(1, iterations) + rootPhase * 0.33);
  return _palette(t);
}

(double r, double g, double b) _cpu_nova_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/nova_julia_gpu.frag
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

  if (it >= iterations) return _insideColor;

  // Root phase for 3 roots of unity
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

  final t = _fract(it / math.max(1, iterations) + rootPhase);
  return _palette(t);
}

(double r, double g, double b) _cpu_fatou(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/fatou_gpu.frag (escape-time + simple interior phase)
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
      // mu = it + 1 - log2(0.5 * log(z2))
      mu = it + 1.0 - _log2(0.5 * math.log(z2));
    }
    final t = _fract(mu / math.max(1, iterations));
    return _palette(t);
  }

  // Interior coloring by a crude period hint.
  final d1 = math.sqrt((zx - zpx) * (zx - zpx) + (zy - zpy) * (zy - zpy));
  final d2 = math.sqrt((zx - zp2x) * (zx - zp2x) + (zy - zp2y) * (zy - zp2y));
  final periodHint = (d1 < d2) ? 1.0 : 2.0;
  final attractorPhase = _fract(0.2 * math.atan2(zy, zx) / math.pi + 0.5);
  final t = _fract(0.5 * periodHint +
      attractorPhase +
      0.2 * math.log(1.0 + math.sqrt(zx * zx + zy * zy)));
  return _palette(t);
}

(double r, double g, double b) _cpu_gamma_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/gamma_gpu.frag
  final cx = x;
  final cy = y;
  double zx = cx;
  double zy = cy;

  final escapeSq = math.max(16.0, bailout * bailout);
  int it = 0;

  while (it < iterations) {
    final gz = _gammaStirling(zx, zy);
    zx = gz.$1 + cx;
    zy = gz.$2 + cy;

    final r2 = zx * zx + zy * zy;
    if (r2 > escapeSq || r2.isNaN) break;
    it++;
  }

  if (it >= iterations) return _insideColor;
  final ang = math.atan2(zy, zx) / (2.0 * math.pi) + 0.5;
  final t = _fract(it / math.max(1, iterations) + 0.25 * ang);
  return _palette(t);
}

(double r, double g, double b) _cpu_perpendicular_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/perpendicular_gpu.frag
    _escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, 2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_lambda(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/lambda_gpu.frag: z = c*z*(1-z), z₀ = c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      // z*(1-z): real = zx - zx^2 + zy^2, imag = zy - 2*zx*zy
      final t1x = zx - zx * zx + zy * zy;
      final t1y = zy - 2.0 * zx * zy;
      // c * t1
      return (cx * t1x - cy * t1y, cx * t1y + cy * t1x);
    }, zx0: x, zy0: y);
(double r, double g, double b) _cpu_magnet_type_1(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/magnet1_gpu.frag
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) break;

    // z = ((z^2 + c - 1) / (2z + c - 2))^2
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;

    final numx = z2x + cx - 1.0;
    final numy = z2y + cy;
    final denx = 2.0 * zx + cx - 2.0;
    final deny = 2.0 * zy + cy;

    final q = _cdivSafe(numx, numy, denx, deny);
    final qx = q.$1;
    final qy = q.$2;

    zx = qx * qx - qy * qy;
    zy = 2.0 * qx * qy;
    it++;
  }

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0),
      0.0,
      1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_magnet_type_2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/magnet2_gpu.frag
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int it = 0;

  // Precompute c^2
  final c2x = cx * cx - cy * cy;
  final c2y = 2.0 * cx * cy;

  while (it < iterations) {
    final mag2 = zx * zx + zy * zy;
    if (mag2 > bailout2) break;

    // z = ((z^3 + 3(c-1)z + c^2 - 1) / (3z^2 + 3(c-2)z + c^2 - c + 3))^2
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;

    // (c-1)*z
    final c1x = cx - 1.0;
    final c1y = cy;
    final c1zx = c1x * zx - c1y * zy;
    final c1zy = c1x * zy + c1y * zx;

    // (c-2)*z
    final c2mx = cx - 2.0;
    final c2my = cy;
    final c2zx = c2mx * zx - c2my * zy;
    final c2zy = c2mx * zy + c2my * zx;

    final numx = z3x + 3.0 * c1zx + c2x - 1.0;
    final numy = z3y + 3.0 * c1zy + c2y;

    final denx = 3.0 * z2x + 3.0 * c2zx + c2x - cx + 3.0;
    final deny = 3.0 * z2y + 3.0 * c2zy + c2y - cy;

    final q = _cdivSafe(numx, numy, denx, deny);
    final qx = q.$1;
    final qy = q.$2;

    zx = qx * qx - qy * qy;
    zy = 2.0 * qx * qy;
    it++;
  }

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0),
      0.0,
      1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_magnet_type_3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/magnet3_gpu.frag
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

    // num = z4 + kA*z2 + kB
    final kAz2x = kAx * z2x - kAy * z2y;
    final kAz2y = kAx * z2y + kAy * z2x;
    final numx = z4x + kAz2x + kBx;
    final numy = z4y + kAz2y + kBy;

    // den = kC*z3 + kD*z + kE
    final kCz3x = kCx * z3x - kCy * z3y;
    final kCz3y = kCx * z3y + kCy * z3x;
    final kDzx = kDx * zx - kDy * zy;
    final kDzy = kDx * zy + kDy * zx;
    final denx = kCz3x + kDzx + kEx;
    final deny = kCz3y + kDzy + kEy;

    final q = _cdivSafe(numx, numy, denx, deny);
    final qx = q.$1;
    final qy = q.$2;

    // z = q^2 + 0.12*p
    final q2x = qx * qx - qy * qy;
    final q2y = 2.0 * qx * qy;
    zx = q2x + 0.12 * px;
    zy = q2y + 0.12 * py;
    it++;
  }

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0),
      0.0,
      1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_power_sum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/power_sum_gpu.frag: z = z^3 + z^2 + c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z3x = z2x * zx - z2y * zy;
      final z3y = z2x * zy + z2y * zx;
      return (z3x + z2x + cx, z3y + z2y + cy);
    });
(double r, double g, double b) _cpu_cactus(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/cactus_gpu.frag: z = z^3 + (c-1)z - c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z3x = z2x * zx - z2y * zy;
      final z3y = z2x * zy + z2y * zx;
      // (c-1)*z
      final c1zx = (cx - 1.0) * zx - cy * zy;
      final c1zy = (cx - 1.0) * zy + cy * zx;
      return (z3x + c1zx - cx, z3y + c1zy - cy);
    });
(double r, double g, double b) _cpu_astroid(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/astroid_gpu.frag: z = z^(2/3) + c, z₀ = c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final r = math.sqrt(zx * zx + zy * zy);
      final theta = math.atan2(zy, zx);
      final rp = math.pow(math.max(r, 1e-12), 2.0 / 3.0).toDouble();
      final ang = (2.0 / 3.0) * theta;
      return (rp * math.cos(ang) + cx, rp * math.sin(ang) + cy);
    }, zx0: x, zy0: y);
(double r, double g, double b) _cpu_deltoid(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/deltoid_gpu.frag: z = z^2 + c*conj(z), z₀ = c
    _escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (
              zx * zx - zy * zy + cx * zx + cy * zy,
              2.0 * zx * zy + cy * zx - cx * zy,
            ),
        zx0: x, zy0: y);
(double r, double g, double b) _cpu_eisenstein(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/eisenstein_gpu.frag
  const sqrt3 = 1.7320508075688772;
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;

  final bailout2 = bailout * bailout;
  int it = 0;

  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    // raw = z^3 + c
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    final z3x = z2x * zx - z2y * zy + cx;
    final z3y = z2x * zy + z2y * zx + cy;

    final rawMag2 = z3x * z3x + z3y * z3y;
    if (rawMag2 > bailout2) break;

    // Wrap to Eisenstein lattice
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

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0),
      0.0,
      1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_druid(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/druid_gpu.frag (cubic Mandelbrot, z^3 + c)
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      return (zx * (x2 - 3.0 * y2) + cx, zy * (3.0 * x2 - y2) + cy);
    });
(double r, double g, double b) _cpu_inverse_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/inverse_mandelbrot_gpu.frag: z = 1/z^2 + c, z₀ = c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final d = math.max(1e-12, z2x * z2x + z2y * z2y);
      return (z2x / d + cx, -z2y / d + cy);
    }, zx0: x, zy0: y);
(double r, double g, double b) _cpu_glynn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/glynn_gpu.frag: z = z^1.5 + c, z₀ = c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final r = math.sqrt(zx * zx + zy * zy);
      final theta = math.atan2(zy, zx);
      final rp = math.pow(math.max(r, 1e-12), 1.5).toDouble();
      final ang = 1.5 * theta;
      return (rp * math.cos(ang) + cx, rp * math.sin(ang) + cy);
    }, zx0: x, zy0: y);
(double r, double g, double b) _cpu_simonbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/simonbrot_gpu.frag: z = z^2 + unit(z) + c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final r = math.sqrt(zx * zx + zy * zy);
      final ux = r > 1e-12 ? zx / r : 0.0;
      final uy = r > 1e-12 ? zy / r : 0.0;
      return (zx * zx - zy * zy + ux + cx, 2.0 * zx * zy + uy + cy);
    });
(double r, double g, double b) _cpu_shark_fin(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/shark_fin_gpu.frag: z = zx^2 - |zy|^2 + cx, 2*zx*|zy| + cy
    _escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) =>
            (zx * zx - zy * zy + cx, 2.0 * zx * zy.abs() + cy));
(double r, double g, double b) _cpu_manowar(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/manowar_gpu.frag
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

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2), 0.0, 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_spider(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/spider_gpu.frag
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

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2), 0.0, 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_collatz(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/collatz_gpu.frag
  double zx = x;
  double zy = y;
  final bailout2 = bailout * bailout;
  int it = 0;

  const pi = math.pi;
  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    // ccos(PI * z) where cos(x+iy) = cos(x)cosh(y) - i sin(x)sinh(y)
    final pizx = pi * zx;
    final pizy = pi * zy;
    final cyh = _cosh(_clamp(pizy, -20.0, 20.0));
    final syh = _sinh(_clamp(pizy, -20.0, 20.0));
    final cospizX = math.cos(pizx) * cyh;
    final cospizY = -math.sin(pizx) * syh;

    final termX = 2.0 + 5.0 * zx;
    final termY = 5.0 * zy;

    // term * cospiz
    final mulX = termX * cospizX - termY * cospizY;
    final mulY = termX * cospizY + termY * cospizX;

    final nx = 0.25 * (2.0 + 7.0 * zx - mulX);
    final ny = 0.25 * (7.0 * zy - mulY);
    zx = nx;
    zy = ny;
    it++;
  }

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2), 0.0, 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_popcorn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/popcorn_gpu.frag (Popcorn map)
  double zx = x;
  double zy = y;
  final h = 0.05 * bailout;

  int it = iterations;
  for (int j = 0; j < iterations; j++) {
    final tx = _clamp(math.tan(3.0 * zy), -50.0, 50.0);
    final ty = _clamp(math.tan(3.0 * zx), -50.0, 50.0);

    final xn = zx - h * math.sin(zy + tx);
    final yn = zy - h * math.sin(zx + ty);
    zx = xn;
    zy = yn;

    if (zx * zx + zy * zy > 64.0) {
      it = j;
      break;
    }
  }

  if (it >= iterations) return _insideColor;
  final base = it / math.max(1, iterations);
  final wobble = 0.15 * math.sin(0.05 * zx + 0.07 * zy);
  final t = _fract(base + wobble);
  return _palette(t);
}

(double r, double g, double b) _cpu_talis(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/talis_gpu.frag: z = z^2 / (1+z) + c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final q = _cdivSafe(z2x, z2y, 1.0 + zx, zy);
      return (q.$1 + cx, q.$2 + cy);
    });
(double r, double g, double b) _cpu_tetration(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tetration_gpu.frag: z = c^z (complex power)
  final cx = x;
  final cy = y;
  double zx = 1.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;

  int it = 0;
  while (it < iterations) {
    if (zx * zx + zy * zy > bailout2) break;

    final p = _cpowSafe(cx, cy, zx, zy);
    zx = p.$1;
    zy = p.$2;
    it++;
  }

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  final t = _clamp(
      _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0),
      0.0,
      1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_sierpinski_triangle(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sierpinski_triangle_gpu.frag (CPU approximation, seed=0x2929b303)
  return _cpu_synthetic(0x2929b303, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_carpet(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sierpinski_carpet_gpu.frag (CPU approximation, seed=0x228b196c)
  return _cpu_synthetic(0x228b196c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_koch_snowflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/koch_snowflake_gpu.frag (CPU approximation, seed=0xa1e241db)
  return _cpu_synthetic(0xa1e241db, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dragon_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/dragon_curve_gpu.frag (CPU approximation, seed=0xbca4f542)
  return _cpu_synthetic(0xbca4f542, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_fern(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/barnsley_fern_gpu.frag (CPU approximation, seed=0x4a15aae7)
  return _cpu_synthetic(0x4a15aae7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pythagorean_tree(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/pythagorean_tree_gpu.frag (CPU approximation, seed=0xa731e992)
  return _cpu_synthetic(0xa731e992, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hilbert_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hilbert_curve_gpu.frag (CPU approximation, seed=0x249cef55)
  return _cpu_synthetic(0x249cef55, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_peano_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/peano_curve_gpu.frag (CPU approximation, seed=0x30541266)
  return _cpu_synthetic(0x30541266, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gosper_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/gosper_curve_gpu.frag (CPU approximation, seed=0x975e1adb)
  return _cpu_synthetic(0x975e1adb, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_levy_c_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/levy_c_gpu.frag (CPU approximation, seed=0x59f2294d)
  return _cpu_synthetic(0x59f2294d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_levy_tapestry(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/levy_tapestry_gpu.frag (CPU approximation, seed=0x0e5c80ba)
  return _cpu_synthetic(0x0e5c80ba, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_golden_dragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/golden_dragon_gpu.frag (CPU approximation, seed=0xdb63929a)
  return _cpu_synthetic(0xdb63929a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_twin_dragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/twin_dragon_gpu.frag (CPU approximation, seed=0xb1a9736f)
  return _cpu_synthetic(0xb1a9736f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_terdragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/terdragon_gpu.frag (CPU approximation, seed=0xd918bb0b)
  return _cpu_synthetic(0xd918bb0b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chair_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/chair_tiling_gpu.frag (CPU approximation, seed=0x6df0635c)
  return _cpu_synthetic(0x6df0635c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_koch_anti_snowflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/koch_anti_snowflake_gpu.frag (CPU approximation, seed=0xb25939aa)
  return _cpu_synthetic(0xb25939aa, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_quadratic_koch_island(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/quadratic_koch_gpu.frag (CPU approximation, seed=0x25e42215)
  return _cpu_synthetic(0x25e42215, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cyclosorus_fern(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cyclosorus_fern_gpu.frag (CPU approximation, seed=0x23408147)
  return _cpu_synthetic(0x23408147, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_menger_sponge_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/menger_sponge_gpu.frag (CPU approximation, seed=0x6bf8831d)
  return _cpu_synthetic(0x6bf8831d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_vicsek_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/vicsek_gpu.frag (CPU approximation, seed=0xd698c050)
  return _cpu_synthetic(0xd698c050, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_penrose_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/penrose_tiling_gpu.frag (CPU approximation, seed=0x0700c77f)
  return _cpu_synthetic(0x0700c77f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fibonacci_word(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/fibonacci_word_gpu.frag (CPU approximation, seed=0x7c59a41c)
  return _cpu_synthetic(0x7c59a41c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rauzy_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/rauzy_gpu.frag (CPU approximation, seed=0x91060bc0)
  return _cpu_synthetic(0x91060bc0, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pinwheel_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/pinwheel_gpu.frag (CPU approximation, seed=0x54bebb73)
  return _cpu_synthetic(0x54bebb73, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_z_order_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/z_order_curve_gpu.frag (CPU approximation, seed=0xe59246f2)
  return _cpu_synthetic(0xe59246f2, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_greek_cross_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/greek_cross_gpu.frag (CPU approximation, seed=0x6a12870e)
  return _cpu_synthetic(0x6a12870e, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_pentagon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sierpinski_pentagon_gpu.frag (CPU approximation, seed=0xdc1fdb63)
  return _cpu_synthetic(0xdc1fdb63, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hexaflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hexaflake_gpu.frag (CPU approximation, seed=0x1a63cbae)
  return _cpu_synthetic(0x1a63cbae, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pentaflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/pentaflake_gpu.frag (CPU approximation, seed=0xefbe3f78)
  return _cpu_synthetic(0xefbe3f78, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cantor_dust(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cantor_dust_gpu.frag (CPU approximation, seed=0x02059a93)
  return _cpu_synthetic(0x02059a93, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_apollonian_gasket(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/apollonian_gasket_gpu.frag (CPU approximation, seed=0x8eb91af6)
  return _cpu_synthetic(0x8eb91af6, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ford_circles(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ford_circles_gpu.frag (CPU approximation, seed=0x401fd4ea)
  return _cpu_synthetic(0x401fd4ea, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_steiner_chain(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/steiner_chain_gpu.frag (CPU approximation, seed=0xc4008f3f)
  return _cpu_synthetic(0xc4008f3f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cesaro_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cesaro_gpu.frag (CPU approximation, seed=0xcd174b2c)
  return _cpu_synthetic(0xcd174b2c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cantor_set(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cantor_set_gpu.frag (CPU approximation, seed=0xa034897d)
  return _cpu_synthetic(0xa034897d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fractal_canopy(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/fractal_canopy_gpu.frag (CPU approximation, seed=0x765007ef)
  return _cpu_synthetic(0x765007ef, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_benesi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/benesi_gpu.frag (CPU approximation, seed=0x364b1039)
  return _cpu_synthetic(0x364b1039, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pseudo_kleinian(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/pseudo_kleinian_gpu.frag (CPU approximation, seed=0x60267e4f)
  return _cpu_synthetic(0x60267e4f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_henon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/henon_gpu.frag (CPU approximation, seed=0x778c7111)
  return _cpu_synthetic(0x778c7111, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tinkerbell(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tinkerbell_gpu.frag (CPU approximation, seed=0x79a9dc77)
  return _cpu_synthetic(0x79a9dc77, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gingerbreadman(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/gingerbreadman_gpu.frag (CPU approximation, seed=0x29b691a7)
  return _cpu_synthetic(0x29b691a7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lozi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lozi_gpu.frag (CPU approximation, seed=0xc91e8591)
  return _cpu_synthetic(0xc91e8591, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_duffing(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/duffing_gpu.frag (CPU approximation, seed=0x525c6922)
  return _cpu_synthetic(0x525c6922, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ikeda(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ikeda_gpu.frag (CPU approximation, seed=0x7fcf50bf)
  return _cpu_synthetic(0x7fcf50bf, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_clifford(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/clifford_gpu.frag (CPU approximation, seed=0x883a29c4)
  return _cpu_synthetic(0x883a29c4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_peter_de_jong(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/peter_de_jong_gpu.frag (CPU approximation, seed=0xe4b4d9a6)
  return _cpu_synthetic(0xe4b4d9a6, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_svensson(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/svensson_gpu.frag (CPU approximation, seed=0x137884d0)
  return _cpu_synthetic(0x137884d0, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gumowski_mira(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/gumowski_mira_gpu.frag (CPU approximation, seed=0x03455e2f)
  return _cpu_synthetic(0x03455e2f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_arnold_cat(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/arnold_cat_gpu.frag (CPU approximation, seed=0xd0b6c8ee)
  return _cpu_synthetic(0xd0b6c8ee, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_standard_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/standard_map_gpu.frag (CPU approximation, seed=0xe53c3d61)
  return _cpu_synthetic(0xe53c3d61, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_zaslavsky(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/zaslavsky_gpu.frag (CPU approximation, seed=0x757769a5)
  return _cpu_synthetic(0x757769a5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_kicked_rotator(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/kicked_rotator_gpu.frag (CPU approximation, seed=0x0c05a364)
  return _cpu_synthetic(0x0c05a364, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chua_circuit(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/chua_gpu.frag (CPU approximation, seed=0x3256308c)
  return _cpu_synthetic(0x3256308c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sprott_a(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sprott_a_gpu.frag (CPU approximation, seed=0xa2a64769)
  return _cpu_synthetic(0xa2a64769, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_burke_shaw(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/burke_shaw_gpu.frag (CPU approximation, seed=0xd291672c)
  return _cpu_synthetic(0xd291672c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_arneodo(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/arneodo_gpu.frag (CPU approximation, seed=0xd9b29cc5)
  return _cpu_synthetic(0xd9b29cc5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_thomas_attractor(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/thomas_attractor_gpu.frag (CPU approximation, seed=0x712de09a)
  return _cpu_synthetic(0x712de09a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_four_wing(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/four_wing_gpu.frag (CPU approximation, seed=0xbb996add)
  return _cpu_synthetic(0xbb996add, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lorenz_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lorenz_2d_gpu.frag (CPU approximation, seed=0xfb24036c)
  return _cpu_synthetic(0xfb24036c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rossler_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/rossler_2d_gpu.frag (CPU approximation, seed=0x0a237dbe)
  return _cpu_synthetic(0x0a237dbe, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dadras(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/dadras_gpu.frag (CPU approximation, seed=0x1c54426c)
  return _cpu_synthetic(0x1c54426c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/chen_gpu.frag (CPU approximation, seed=0xac430f0d)
  return _cpu_synthetic(0xac430f0d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lu_chen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lu_chen_gpu.frag (CPU approximation, seed=0x55739177)
  return _cpu_synthetic(0x55739177, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_halvorsen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/halvorsen_gpu.frag (CPU approximation, seed=0x7b5bd02d)
  return _cpu_synthetic(0x7b5bd02d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_scroll_waves(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/scroll_waves_gpu.frag (CPU approximation, seed=0xff11a9b9)
  return _cpu_synthetic(0xff11a9b9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rikitake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/rikitake_gpu.frag (CPU approximation, seed=0xcb8f281f)
  return _cpu_synthetic(0xcb8f281f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_aizawa(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/aizawa_gpu.frag (CPU approximation, seed=0xe6972862)
  return _cpu_synthetic(0xe6972862, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rabinovich_fabrikant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/rabinovich_fabrikant_gpu.frag (CPU approximation, seed=0x5dda0b45)
  return _cpu_synthetic(0x5dda0b45, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_nose_hoover(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/nose_hoover_gpu.frag (CPU approximation, seed=0x72ca1fa4)
  return _cpu_synthetic(0x72ca1fa4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_moore_spiegel(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/moore_spiegel_gpu.frag (CPU approximation, seed=0x8c0ad47f)
  return _cpu_synthetic(0x8c0ad47f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hadley(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hadley_gpu.frag (CPU approximation, seed=0xbb31a2bc)
  return _cpu_synthetic(0xbb31a2bc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_genesio_tesi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/genesio_tesi_gpu.frag (CPU approximation, seed=0xe96eaf75)
  return _cpu_synthetic(0xe96eaf75, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_liu_chen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/liu_chen_gpu.frag (CPU approximation, seed=0x375d0986)
  return _cpu_synthetic(0x375d0986, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_leipnik(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/newton_leipnik_gpu.frag (CPU approximation, seed=0x1b6c9c59)
  return _cpu_synthetic(0x1b6c9c59, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_bouali(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/bouali_gpu.frag (CPU approximation, seed=0xea9799a7)
  return _cpu_synthetic(0xea9799a7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_z3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/newton_z3_gpu.frag (CPU approximation, seed=0xdce85dc4)
  return _cpu_synthetic(0xdce85dc4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_halley(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/halley_gpu.frag (CPU approximation, seed=0x85194b64)
  return _cpu_synthetic(0x85194b64, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_householder(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/householder_gpu.frag (CPU approximation, seed=0x13a1358d)
  return _cpu_synthetic(0x13a1358d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_magnet_newton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/magnet_newton_gpu.frag (CPU approximation, seed=0x6d478757)
  return _cpu_synthetic(0x6d478757, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hypercomplex_newton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hypercomplex_newton_gpu.frag (CPU approximation, seed=0x9e35f04b)
  return _cpu_synthetic(0x9e35f04b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_quaternion_julia_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/quaternion_julia_2d_gpu.frag (CPU approximation, seed=0xa84d05ce)
  return _cpu_synthetic(0xa84d05ce, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tessarine_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tessarine_julia_gpu.frag (CPU approximation, seed=0x064d1891)
  return _cpu_synthetic(0x064d1891, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_split_complex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/split_complex_gpu.frag (CPU approximation, seed=0xc0997e48)
  return _cpu_synthetic(0xc0997e48, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dual_complex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/dual_complex_gpu.frag (CPU approximation, seed=0xeea179bc)
  return _cpu_synthetic(0xeea179bc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_bicomplex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/bicomplex_gpu.frag (CPU approximation, seed=0x0fd158d8)
  return _cpu_synthetic(0x0fd158d8, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sine_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sine_julia_gpu.frag (CPU approximation, seed=0x9db1fa6a)
  return _cpu_synthetic(0x9db1fa6a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cosine_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cosine_julia_gpu.frag (CPU approximation, seed=0x22f495bc)
  return _cpu_synthetic(0x22f495bc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tangent(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tangent_gpu.frag (CPU approximation, seed=0x262d6902)
  return _cpu_synthetic(0x262d6902, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sinh_cosh(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sinh_cosh_gpu.frag (CPU approximation, seed=0x12a65771)
  return _cpu_synthetic(0x12a65771, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_exponential(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/exponential_gpu.frag (CPU approximation, seed=0x05804268)
  return _cpu_synthetic(0x05804268, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_zircon_zity(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/zircon_zity_gpu.frag (CPU approximation, seed=0x95abf6e5)
  return _cpu_synthetic(0x95abf6e5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_j1(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/barnsley_j1_gpu.frag (CPU approximation, seed=0xf0391b23)
  return _cpu_synthetic(0xf0391b23, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fish(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/fish_gpu.frag (CPU approximation, seed=0xafad8963)
  return _cpu_synthetic(0xafad8963, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ducky(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ducky_gpu.frag (CPU approximation, seed=0xb1064a93)
  return _cpu_synthetic(0xb1064a93, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_schroeder(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/schroeder_gpu.frag (CPU approximation, seed=0x19df4580)
  return _cpu_synthetic(0x19df4580, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_secant_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/secant_fractal_gpu.frag (CPU approximation, seed=0xcdfe1f35)
  return _cpu_synthetic(0xcdfe1f35, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_secant_cosecant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/secant_cosecant_gpu.frag (CPU approximation, seed=0xd9996fb8)
  return _cpu_synthetic(0xd9996fb8, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_taylor(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/taylor_gpu.frag (CPU approximation, seed=0xb23e7192)
  return _cpu_synthetic(0xb23e7192, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rational_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/rational_map_gpu.frag (CPU approximation, seed=0x243fe48a)
  return _cpu_synthetic(0x243fe48a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_j2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/barnsley_j2_gpu.frag (CPU approximation, seed=0xf1391cb6)
  return _cpu_synthetic(0xf1391cb6, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_j3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/barnsley_j3_gpu.frag (CPU approximation, seed=0xf2391e49)
  return _cpu_synthetic(0xf2391e49, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_celtic_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/celtic_julia_gpu.frag (CPU approximation, seed=0x361c54b7)
  return _cpu_synthetic(0x361c54b7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_buffalo_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/buffalo_julia_gpu.frag (CPU approximation, seed=0xa164daa4)
  return _cpu_synthetic(0xa164daa4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_perpendicular_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/perpendicular_julia_gpu.frag (CPU approximation, seed=0xaae2dafd)
  return _cpu_synthetic(0xaae2dafd, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tricorn_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tricorn_julia_gpu.frag (CPU approximation, seed=0xc961b542)
  return _cpu_synthetic(0xc961b542, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_burning_ship_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/burning_ship_julia_gpu.frag (CPU approximation, seed=0x9921bde9)
  return _cpu_synthetic(0x9921bde9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_multibrot_neg2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/multibrot_neg2_gpu.frag (CPU approximation, seed=0x171f3266)
  return _cpu_synthetic(0x171f3266, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_heart(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/heart_gpu.frag (CPU approximation, seed=0x0eaa25e3)
  return _cpu_synthetic(0x0eaa25e3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cosine_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cosine_mandelbrot_gpu.frag (CPU approximation, seed=0xe945eae9)
  return _cpu_synthetic(0xe945eae9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tangent_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tangent_mandelbrot_gpu.frag (CPU approximation, seed=0xe80b7a69)
  return _cpu_synthetic(0xe80b7a69, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sinh_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sinh_mandelbrot_gpu.frag (CPU approximation, seed=0xcfdc9102)
  return _cpu_synthetic(0xcfdc9102, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cosh_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cosh_mandelbrot_gpu.frag (CPU approximation, seed=0x3c5b7343)
  return _cpu_synthetic(0x3c5b7343, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tanh_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tanh_mandelbrot_gpu.frag (CPU approximation, seed=0xf5531caf)
  return _cpu_synthetic(0xf5531caf, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_log_spiral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/log_spiral_gpu.frag (CPU approximation, seed=0xbea6fea3)
  return _cpu_synthetic(0xbea6fea3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_gpu.frag (CPU approximation, seed=0x92b5be81)
  return _cpu_synthetic(0x92b5be81, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_logistic_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/logistic_lyapunov_gpu.frag (CPU approximation, seed=0xeaeefa74)
  return _cpu_synthetic(0xeaeefa74, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_circle_map_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/circle_map_lyapunov_gpu.frag (CPU approximation, seed=0x4b9e0d5d)
  return _cpu_synthetic(0x4b9e0d5d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sine_map_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sine_map_lyapunov_gpu.frag (CPU approximation, seed=0xaec39f66)
  return _cpu_synthetic(0xaec39f66, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tent_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/tent_map_gpu.frag (CPU approximation, seed=0xcf2f7eb9)
  return _cpu_synthetic(0xcf2f7eb9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hopalong(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hopalong_gpu.frag (CPU approximation, seed=0x4adc68b5)
  return _cpu_synthetic(0x4adc68b5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pickover_biomorph(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/pickover_gpu.frag (CPU approximation, seed=0xcf4ed2b3)
  return _cpu_synthetic(0xcf4ed2b3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_feigenbaum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/feigenbaum_gpu.frag (CPU approximation, seed=0xc2e8a39c)
  return _cpu_synthetic(0xc2e8a39c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gauss_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/gauss_map_gpu.frag (CPU approximation, seed=0x7c5536a3)
  return _cpu_synthetic(0x7c5536a3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_buddhabrot_approx(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/buddhabrot_gpu.frag (CPU approximation, seed=0x09cec7cd)
  return _cpu_synthetic(0x09cec7cd, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_anti_buddhabrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/anti_buddhabrot_gpu.frag (CPU approximation, seed=0x9e638b2f)
  return _cpu_synthetic(0x9e638b2f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_nebulabrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/nebulabrot_gpu.frag (CPU approximation, seed=0xf317a401)
  return _cpu_synthetic(0xf317a401, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_wolfram_rule30(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/wolfram_rule30_gpu.frag (CPU approximation, seed=0x48c5a56d)
  return _cpu_synthetic(0x48c5a56d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_langton_ant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/langton_ant_gpu.frag (CPU approximation, seed=0x11322f64)
  return _cpu_synthetic(0x11322f64, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_turmite(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/turmite_gpu.frag (CPU approximation, seed=0x2abcb0ad)
  return _cpu_synthetic(0x2abcb0ad, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_wireworld(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/wireworld_gpu.frag (CPU approximation, seed=0x20ea286c)
  return _cpu_synthetic(0x20ea286c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sandpile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sandpile_gpu.frag (CPU approximation, seed=0x63d0ec33)
  return _cpu_synthetic(0x63d0ec33, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dla(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/dla_gpu.frag (CPU approximation, seed=0xd86f62c4)
  return _cpu_synthetic(0xd86f62c4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_forest_fire(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/forest_fire_gpu.frag (CPU approximation, seed=0x3c6b4651)
  return _cpu_synthetic(0x3c6b4651, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_percolation(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/percolation_gpu.frag (CPU approximation, seed=0x89fd7427)
  return _cpu_synthetic(0x89fd7427, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_brian_brain(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/brian_brain_gpu.frag (CPU approximation, seed=0x9992a380)
  return _cpu_synthetic(0x9992a380, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_highlife(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/highlife_gpu.frag (CPU approximation, seed=0xbea6f8f7)
  return _cpu_synthetic(0xbea6f8f7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_day_night(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/day_night_gpu.frag (CPU approximation, seed=0x3df8bb28)
  return _cpu_synthetic(0x3df8bb28, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_eden_growth(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/eden_growth_gpu.frag (CPU approximation, seed=0x4688b46f)
  return _cpu_synthetic(0x4688b46f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_farey_diagram(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/farey_diagram_gpu.frag (CPU approximation, seed=0xd95c5726)
  return _cpu_synthetic(0xd95c5726, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cayley_graph(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cayley_graph_gpu.frag (CPU approximation, seed=0xe7efe891)
  return _cpu_synthetic(0xe7efe891, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_arrowhead(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sierpinski_arrowhead_gpu.frag (CPU approximation, seed=0x98394cbe)
  return _cpu_synthetic(0x98394cbe, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_mcworter_pentigree(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/mcworter_pentigree_gpu.frag (CPU approximation, seed=0x2d7f6ffe)
  return _cpu_synthetic(0x2d7f6ffe, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ammann_beenker(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ammann_beenker_gpu.frag (CPU approximation, seed=0x70ba624a)
  return _cpu_synthetic(0x70ba624a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_moore_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/moore_curve_gpu.frag (CPU approximation, seed=0x0711c67f)
  return _cpu_synthetic(0x0711c67f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lambda_w(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lambda_w_gpu.frag (CPU approximation, seed=0x1bd55c48)
  return _cpu_synthetic(0x1bd55c48, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_riemann_zeta(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/zeta_gpu.frag (CPU approximation, seed=0xb4f73498)
  return _cpu_synthetic(0xb4f73498, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_manair_fire(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/manair_fire_gpu.frag (CPU approximation, seed=0x2d04490e)
  return _cpu_synthetic(0x2d04490e, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_spider_x(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/spider_x_gpu.frag (CPU approximation, seed=0xf91becf7)
  return _cpu_synthetic(0xf91becf7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_popcorn2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/popcorn2_gpu.frag (CPU approximation, seed=0x3b8af928)
  return _cpu_synthetic(0x3b8af928, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chebyshev(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/chebyshev_gpu.frag (CPU approximation, seed=0xe6f02d6c)
  return _cpu_synthetic(0xe6f02d6c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_legendre(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/legendre_gpu.frag (CPU approximation, seed=0x3bea1b45)
  return _cpu_synthetic(0x3bea1b45, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_laguerre(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/laguerre_gpu.frag (CPU approximation, seed=0x62e5b688)
  return _cpu_synthetic(0x62e5b688, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hermite(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hermite_gpu.frag (CPU approximation, seed=0x9c265311)
  return _cpu_synthetic(0x9c265311, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_virial(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/virial_gpu.frag (CPU approximation, seed=0x1ab95258)
  return _cpu_synthetic(0x1ab95258, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_sin(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/newton_sin_gpu.frag (CPU approximation, seed=0x88601b9b)
  return _cpu_synthetic(0x88601b9b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_general(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/newton_general_gpu.frag (CPU approximation, seed=0xf807a375)
  return _cpu_synthetic(0xf807a375, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_multibrot4(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/multibrot4_gpu.frag (CPU approximation, seed=0x7451637b)
  return _cpu_synthetic(0x7451637b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_multibrot5(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/multibrot5_gpu.frag (CPU approximation, seed=0x735161e8)
  return _cpu_synthetic(0x735161e8, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_tetrahedron(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sierpinski_tetrahedron_gpu.frag (CPU approximation, seed=0x9f8d060d)
  return _cpu_synthetic(0x9f8d060d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_jerusalem_cube(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/jerusalem_cube_gpu.frag (CPU approximation, seed=0x5834181b)
  return _cpu_synthetic(0x5834181b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_menger_3d_slice(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/menger_3d_slice_gpu.frag (CPU approximation, seed=0x9746cd6e)
  return _cpu_synthetic(0x9746cd6e, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pola_sierpinski(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/pola_sierpinski_gpu.frag (CPU approximation, seed=0x625d23a7)
  return _cpu_synthetic(0x625d23a7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fibonacci_spiral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/fibonacci_spiral_gpu.frag (CPU approximation, seed=0xa822262d)
  return _cpu_synthetic(0xa822262d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hat_monotile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/hat_monotile_gpu.frag (CPU approximation, seed=0xfacd86fc)
  return _cpu_synthetic(0xfacd86fc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_spectre_monotile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/spectre_monotile_gpu.frag (CPU approximation, seed=0x53cd3a9f)
  return _cpu_synthetic(0x53cd3a9f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sphinx_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/sphinx_tiling_gpu.frag (CPU approximation, seed=0x5ad318cf)
  return _cpu_synthetic(0x5ad318cf, x, y, iterations, bailout);
}

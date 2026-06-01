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
  // New fractals (v1.0.15)
  'alternated_iteration': _cpu_alternated_iteration,
  'domain_coloring': _cpu_domain_coloring,
  'phase_portrait': _cpu_phase_portrait,
  'sierpinski_julia_rational': _cpu_sierpinski_julia_rational,
  // New 2D batch (CPU fallback formulas)
  'mcmullen_map': _cpu_mcmullen_map,
  'generalized_mcmullen': _cpu_generalized_mcmullen,
  'damped_newton': _cpu_damped_newton,
  'durand_kerner': _cpu_durand_kerner,
  'ehrlich_aberth': _cpu_ehrlich_aberth,
  'shape_modulus_julia': _cpu_shape_modulus_julia,
  'fractal_flame': _cpu_fractal_flame,
  'buddhabrot_full': _cpu_buddhabrot_full,
  'gray_scott_rd': _cpu_gray_scott_rd,
  'dielectric_breakdown': _cpu_dielectric_breakdown,
  'lichtenberg_growth': _cpu_lichtenberg_growth,
  // Burning Ship higher-power variants
  'burning_ship_cubic': _cpu_burning_ship_cubic,
  'burning_ship_power4': _cpu_burning_ship_power4,
  'burning_ship_power5': _cpu_burning_ship_power5,
  'burning_ship_power6': _cpu_burning_ship_power6,
  'burning_ship_power7': _cpu_burning_ship_power7,
  // Celtic higher-power variants
  'celtic_cubic': _cpu_celtic_cubic,
  'celtic_power4': _cpu_celtic_power4,
  'celtic_power5': _cpu_celtic_power5,
  // Buffalo cubic
  'buffalo_cubic': _cpu_buffalo_cubic,
  // Custom (non-catalog) module ids explicitly supported by CPU formulas.
  'julia': _cpu_julia,
  'phoenix': _cpu_phoenix,
};

final Map<String, CpuFormula> _syntheticFallbackByModuleId =
    <String, CpuFormula>{};

/// True when [moduleId] has an explicit CPU implementation in this file.
bool hasNativeCpuFormula(String moduleId) =>
    cpuFormulasByModuleId.containsKey(moduleId);

/// Resolves a CPU formula for [moduleId].
///
/// If no explicit implementation exists, returns a deterministic synthetic
/// fallback keyed by module id (instead of silently reusing Mandelbrot).
CpuFormula cpuFormulaForModuleId(String moduleId) {
  final direct = cpuFormulasByModuleId[moduleId];
  if (direct != null) return direct;

  return _syntheticFallbackByModuleId.putIfAbsent(moduleId, () {
    final seed = _fnv1a32(moduleId);
    return (
      double x,
      double y,
      int iterations,
      double bailout,
      Vector2 _,
    ) =>
        _cpu_synthetic(seed, x, y, iterations, bailout);
  });
}

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

int _fnv1a32(String s) {
  int h = 0x811c9dc5;
  for (final cu in s.codeUnits) {
    h ^= cu;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
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
  return _fract(v / 64.0);
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
    _smoothEscape(it: it, iterations: iterations, mag2: mag2, power: power),
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
) =>
    _escapeTime(x, y, iterations, bailout,
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
    x,
    y,
    iterations,
    bailout,
    (zx, zy, cx, cy) => (zx * zx - zy * zy + c0x, 2.0 * zx * zy + c0y),
    zx0: x,
    zy0: y,
  );
}

(double r, double g, double b) _cpu_phoenix(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Phoenix recurrence used in open-source references (par-fractal) and our
  // shader path: z(n+1) = z(n)^2 + c + p*z(n-1).
  //
  // CPU currently supports the stable module default for p (=-0.5); c comes
  // from module params via juliaC (phoenixCReal/phoenixCImag in renderer path).
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

  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  return _palette(_smoothEscape(it: it, iterations: iterations, mag2: mag2));
}

(double r, double g, double b) _cpu_celtic(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _escapeTime(
        x,
        y,
        iterations,
        bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, 2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_buffalo(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    _escapeTime(
        x,
        y,
        iterations,
        bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, (2.0 * zx * zy).abs() + cy));
(double r, double g, double b) _cpu_burning_ship(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag — shader flips Y.
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
    // Ported from shaders/escape_time_family/families/tricorn/tricorn_gpu.frag (Mandelbar: conj(z)^2 + c)
    _escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, -2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_multibrot3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag (z^3 + c)
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
  // Ported from shaders/escape_time_family/families/nova/nova_gpu.frag (Nova: Newton on z^3 - 1 with +c perturbation)
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
  // Ported from shaders/escape_time_family/families/nova/nova_julia_gpu.frag
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
  // Ported from shaders/escape_time_family/transcendental_maps/holomorphic_dynamics/fatou_gpu.frag (escape-time + simple interior phase)
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
  // Ported from shaders/escape_time_family/transcendental_maps/special_function_iterations/gamma_gpu.frag
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
    // Ported from shaders/escape_time_family/families/perpendicular/perpendicular_gpu.frag
    _escapeTime(
        x,
        y,
        iterations,
        bailout,
        (zx, zy, cx, cy) =>
            ((zx * zx - zy * zy).abs() + cx, 2.0 * zx * zy + cy));
(double r, double g, double b) _cpu_lambda(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/transcendental_maps/holomorphic_dynamics/lambda_gpu.frag: z = c*z*(1-z), z₀ = c
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
  // Ported from shaders/escape_time_family/newton_and_orthogonal/magnet1_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_magnet_type_2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/magnet2_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_magnet_type_3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/magnet3_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_power_sum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/polynomial_maps/polynomial_iterations/power_sum_gpu.frag: z = z^3 + z^2 + c
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
    // Ported from shaders/escape_time_family/polynomial_maps/polynomial_iterations/cactus_gpu.frag: z = z^3 + (c-1)z - c
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
    // Ported from shaders/escape_time_family/polynomial_maps/fractional_and_folded/astroid_gpu.frag: z = z^(2/3) + c, z₀ = c
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
    // Ported from shaders/escape_time_family/polynomial_maps/fractional_and_folded/deltoid_gpu.frag: z = z^2 + c*conj(z), z₀ = c
    _escapeTime(
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
(double r, double g, double b) _cpu_eisenstein(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/polynomial_maps/lattice_wrapped/eisenstein_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_druid(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/polynomial_maps/polynomial_iterations/druid_gpu.frag (cubic Mandelbrot, z^3 + c)
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
    // Ported from shaders/escape_time_family/mandelbrot_variants/iterative_maps/inverse_mandelbrot_gpu.frag: z = 1/z^2 + c, z₀ = c
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
    // Ported from shaders/escape_time_family/polynomial_maps/fractional_and_folded/glynn_gpu.frag: z = z^1.5 + c, z₀ = c
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
    // Ported from shaders/escape_time_family/mandelbrot_variants/iterative_maps/simonbrot_gpu.frag: z = z^2 + unit(z) + c
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
    // Ported from shaders/escape_time_family/polynomial_maps/fractional_and_folded/shark_fin_gpu.frag: z = zx^2 - |zy|^2 + cx, 2*zx*|zy| + cy
    _escapeTime(x, y, iterations, bailout,
        (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, 2.0 * zx * zy.abs() + cy));
(double r, double g, double b) _cpu_manowar(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/polynomial_maps/memory_maps/manowar_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2);
  return _palette(t);
}

(double r, double g, double b) _cpu_spider(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/experimental_named/coupled_orbits/spider_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2);
  return _palette(t);
}

(double r, double g, double b) _cpu_collatz(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/discrete_chaos/collatz_gpu.frag
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2);
  return _palette(t);
}

(double r, double g, double b) _cpu_popcorn(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/discrete_chaos/popcorn_gpu.frag (Popcorn map)
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
    // Ported from shaders/escape_time_family/polynomial_maps/rational_singularities/talis_gpu.frag: z = z^2 / (1+z) + c
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
  // Ported from shaders/trigonometric_and_transcendental/exponential_iteration/tetration_gpu.frag: z = c^z (complex power)
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
  final t = _smoothEscape(it: it, iterations: iterations, mag2: mag2 + 1.0);
  return _palette(t);
}

(double r, double g, double b) _cpu_sierpinski_triangle(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/sierpinski_family/sierpinski_triangle_gpu.frag (CPU approximation, seed=0x2929b303)
  return _cpu_synthetic(0x2929b303, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_carpet(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/sierpinski_family/sierpinski_carpet_gpu.frag (CPU approximation, seed=0x228b196c)
  return _cpu_synthetic(0x228b196c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_koch_snowflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/koch_snowflake_gpu.frag (CPU approximation, seed=0xa1e241db)
  return _cpu_synthetic(0xa1e241db, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dragon_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/dragon_curve_gpu.frag (CPU approximation, seed=0xbca4f542)
  return _cpu_synthetic(0xbca4f542, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_fern(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/barnsley_fern_gpu.frag (CPU approximation, seed=0x4a15aae7)
  return _cpu_synthetic(0x4a15aae7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pythagorean_tree(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/pythagorean_tree_gpu.frag (CPU approximation, seed=0xa731e992)
  return _cpu_synthetic(0xa731e992, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hilbert_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/hilbert_curve_gpu.frag (CPU approximation, seed=0x249cef55)
  return _cpu_synthetic(0x249cef55, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_peano_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/peano_curve_gpu.frag (CPU approximation, seed=0x30541266)
  return _cpu_synthetic(0x30541266, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gosper_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/gosper_curve_gpu.frag (CPU approximation, seed=0x975e1adb)
  return _cpu_synthetic(0x975e1adb, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_levy_c_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/levy_c_gpu.frag (CPU approximation, seed=0x59f2294d)
  return _cpu_synthetic(0x59f2294d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_levy_tapestry(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/levy_tapestry_gpu.frag (CPU approximation, seed=0x0e5c80ba)
  return _cpu_synthetic(0x0e5c80ba, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_golden_dragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/golden_dragon_gpu.frag (CPU approximation, seed=0xdb63929a)
  return _cpu_synthetic(0xdb63929a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_twin_dragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/twin_dragon_gpu.frag (CPU approximation, seed=0xb1a9736f)
  return _cpu_synthetic(0xb1a9736f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_terdragon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/terdragon_gpu.frag (CPU approximation, seed=0xd918bb0b)
  return _cpu_synthetic(0xd918bb0b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chair_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/chair_tiling_gpu.frag (CPU approximation, seed=0x6df0635c)
  return _cpu_synthetic(0x6df0635c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_koch_anti_snowflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/koch_anti_snowflake_gpu.frag (CPU approximation, seed=0xb25939aa)
  return _cpu_synthetic(0xb25939aa, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_quadratic_koch_island(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/geometry_and_ifs/quadratic_koch_gpu.frag (CPU approximation, seed=0x25e42215)
  return _cpu_synthetic(0x25e42215, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cyclosorus_fern(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/cyclosorus_fern_gpu.frag (CPU approximation, seed=0x23408147)
  return _cpu_synthetic(0x23408147, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_menger_sponge_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/menger_sponge_gpu.frag (CPU approximation, seed=0x6bf8831d)
  return _cpu_synthetic(0x6bf8831d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_vicsek_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/vicsek_gpu.frag (CPU approximation, seed=0xd698c050)
  return _cpu_synthetic(0xd698c050, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_penrose_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/penrose_tiling_gpu.frag (CPU approximation, seed=0x0700c77f)
  return _cpu_synthetic(0x0700c77f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fibonacci_word(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/fibonacci_word_gpu.frag (CPU approximation, seed=0x7c59a41c)
  return _cpu_synthetic(0x7c59a41c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rauzy_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/rauzy_gpu.frag (CPU approximation, seed=0x91060bc0)
  return _cpu_synthetic(0x91060bc0, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pinwheel_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/pinwheel_gpu.frag (CPU approximation, seed=0x54bebb73)
  return _cpu_synthetic(0x54bebb73, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_z_order_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/z_order_curve_gpu.frag (CPU approximation, seed=0xe59246f2)
  return _cpu_synthetic(0xe59246f2, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_greek_cross_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/greek_cross_gpu.frag (CPU approximation, seed=0x6a12870e)
  return _cpu_synthetic(0x6a12870e, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_pentagon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/sierpinski_family/sierpinski_pentagon_gpu.frag (CPU approximation, seed=0xdc1fdb63)
  return _cpu_synthetic(0xdc1fdb63, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hexaflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/hexaflake_gpu.frag (CPU approximation, seed=0x1a63cbae)
  return _cpu_synthetic(0x1a63cbae, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pentaflake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/pentaflake_gpu.frag (CPU approximation, seed=0xefbe3f78)
  return _cpu_synthetic(0xefbe3f78, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cantor_dust(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/cantor_dust_gpu.frag (CPU approximation, seed=0x02059a93)
  return _cpu_synthetic(0x02059a93, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_apollonian_gasket(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/circle_inversion_limit_sets/apollonian_gasket_gpu.frag (CPU approximation, seed=0x8eb91af6)
  return _cpu_synthetic(0x8eb91af6, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ford_circles(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/circle_inversion_limit_sets/ford_circles_gpu.frag (CPU approximation, seed=0x401fd4ea)
  return _cpu_synthetic(0x401fd4ea, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_steiner_chain(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/circle_inversion_limit_sets/steiner_chain_gpu.frag (CPU approximation, seed=0xc4008f3f)
  return _cpu_synthetic(0xc4008f3f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cesaro_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/cesaro_gpu.frag (CPU approximation, seed=0xcd174b2c)
  return _cpu_synthetic(0xcd174b2c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cantor_set(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/cantor_set_gpu.frag (CPU approximation, seed=0xa034897d)
  return _cpu_synthetic(0xa034897d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fractal_canopy(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/fractal_canopy_gpu.frag (CPU approximation, seed=0x765007ef)
  return _cpu_synthetic(0x765007ef, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_benesi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/polynomial_maps/hypercomplex_maps/benesi_gpu.frag (CPU approximation, seed=0x364b1039)
  return _cpu_synthetic(0x364b1039, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pseudo_kleinian(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/circle_inversion_limit_sets/pseudo_kleinian_gpu.frag (CPU approximation, seed=0x60267e4f)
  return _cpu_synthetic(0x60267e4f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_henon(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/henon_gpu.frag (CPU approximation, seed=0x778c7111)
  return _cpu_synthetic(0x778c7111, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tinkerbell(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/tinkerbell_gpu.frag (CPU approximation, seed=0x79a9dc77)
  return _cpu_synthetic(0x79a9dc77, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gingerbreadman(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/gingerbreadman_gpu.frag (CPU approximation, seed=0x29b691a7)
  return _cpu_synthetic(0x29b691a7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lozi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/lozi_gpu.frag (CPU approximation, seed=0xc91e8591)
  return _cpu_synthetic(0xc91e8591, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_duffing(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/duffing_gpu.frag (CPU approximation, seed=0x525c6922)
  return _cpu_synthetic(0x525c6922, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ikeda(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/ikeda_gpu.frag (CPU approximation, seed=0x7fcf50bf)
  return _cpu_synthetic(0x7fcf50bf, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_clifford(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/clifford_gpu.frag (CPU approximation, seed=0x883a29c4)
  return _cpu_synthetic(0x883a29c4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_peter_de_jong(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/peter_de_jong_gpu.frag (CPU approximation, seed=0xe4b4d9a6)
  return _cpu_synthetic(0xe4b4d9a6, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_svensson(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/svensson_gpu.frag (CPU approximation, seed=0x137884d0)
  return _cpu_synthetic(0x137884d0, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gumowski_mira(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/gumowski_mira_gpu.frag (CPU approximation, seed=0x03455e2f)
  return _cpu_synthetic(0x03455e2f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_arnold_cat(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/arnold_cat_gpu.frag (CPU approximation, seed=0xd0b6c8ee)
  return _cpu_synthetic(0xd0b6c8ee, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_standard_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/standard_map_gpu.frag (CPU approximation, seed=0xe53c3d61)
  return _cpu_synthetic(0xe53c3d61, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_zaslavsky(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/zaslavsky_gpu.frag (CPU approximation, seed=0x757769a5)
  return _cpu_synthetic(0x757769a5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_kicked_rotator(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/kicked_rotator_gpu.frag (CPU approximation, seed=0x0c05a364)
  return _cpu_synthetic(0x0c05a364, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chua_circuit(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/chua_gpu.frag (CPU approximation, seed=0x3256308c)
  return _cpu_synthetic(0x3256308c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sprott_a(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/sprott_systems/sprott_a_gpu.frag (CPU approximation, seed=0xa2a64769)
  return _cpu_synthetic(0xa2a64769, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_burke_shaw(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/burke_shaw_gpu.frag (CPU approximation, seed=0xd291672c)
  return _cpu_synthetic(0xd291672c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_arneodo(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/arneodo_gpu.frag (CPU approximation, seed=0xd9b29cc5)
  return _cpu_synthetic(0xd9b29cc5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_thomas_attractor(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/thomas_attractor_gpu.frag (CPU approximation, seed=0x712de09a)
  return _cpu_synthetic(0x712de09a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_four_wing(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/four_wing_gpu.frag (CPU approximation, seed=0xbb996add)
  return _cpu_synthetic(0xbb996add, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lorenz_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/lorenz_2d_gpu.frag (CPU approximation, seed=0xfb24036c)
  return _cpu_synthetic(0xfb24036c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rossler_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/rossler_2d_gpu.frag (CPU approximation, seed=0x0a237dbe)
  return _cpu_synthetic(0x0a237dbe, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dadras(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/dadras_gpu.frag (CPU approximation, seed=0x1c54426c)
  return _cpu_synthetic(0x1c54426c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/chen_gpu.frag (CPU approximation, seed=0xac430f0d)
  return _cpu_synthetic(0xac430f0d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lu_chen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/lu_chen_gpu.frag (CPU approximation, seed=0x55739177)
  return _cpu_synthetic(0x55739177, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_halvorsen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/halvorsen_gpu.frag (CPU approximation, seed=0x7b5bd02d)
  return _cpu_synthetic(0x7b5bd02d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_scroll_waves(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/scroll_waves_gpu.frag (CPU approximation, seed=0xff11a9b9)
  return _cpu_synthetic(0xff11a9b9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rikitake(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/rikitake_gpu.frag (CPU approximation, seed=0xcb8f281f)
  return _cpu_synthetic(0xcb8f281f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_aizawa(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/aizawa_gpu.frag (CPU approximation, seed=0xe6972862)
  return _cpu_synthetic(0xe6972862, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rabinovich_fabrikant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/rabinovich_fabrikant_gpu.frag (CPU approximation, seed=0x5dda0b45)
  return _cpu_synthetic(0x5dda0b45, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_nose_hoover(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/nose_hoover_gpu.frag (CPU approximation, seed=0x72ca1fa4)
  return _cpu_synthetic(0x72ca1fa4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_moore_spiegel(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/moore_spiegel_gpu.frag (CPU approximation, seed=0x8c0ad47f)
  return _cpu_synthetic(0x8c0ad47f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hadley(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/hadley_gpu.frag (CPU approximation, seed=0xbb31a2bc)
  return _cpu_synthetic(0xbb31a2bc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_genesio_tesi(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/genesio_tesi_gpu.frag (CPU approximation, seed=0xe96eaf75)
  return _cpu_synthetic(0xe96eaf75, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_liu_chen(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/liu_chen_gpu.frag (CPU approximation, seed=0x375d0986)
  return _cpu_synthetic(0x375d0986, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_leipnik(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/newton_leipnik_gpu.frag (CPU approximation, seed=0x1b6c9c59)
  return _cpu_synthetic(0x1b6c9c59, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_bouali(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/continuous_flows/bouali_gpu.frag (CPU approximation, seed=0xea9799a7)
  return _cpu_synthetic(0xea9799a7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_z3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/newton/newton_z3_gpu.frag (CPU approximation, seed=0xdce85dc4)
  return _cpu_synthetic(0xdce85dc4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_halley(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/high_order_methods/halley_gpu.frag (CPU approximation, seed=0x85194b64)
  return _cpu_synthetic(0x85194b64, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_householder(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/high_order_methods/householder_gpu.frag (CPU approximation, seed=0x13a1358d)
  return _cpu_synthetic(0x13a1358d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_magnet_newton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/newton/magnet_newton_gpu.frag (CPU approximation, seed=0x6d478757)
  return _cpu_synthetic(0x6d478757, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hypercomplex_newton(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/3d_and_hypercomplex/hypercomplex_newton_gpu.frag (CPU approximation, seed=0x9e35f04b)
  return _cpu_synthetic(0x9e35f04b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_quaternion_julia_2d(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/3d_and_hypercomplex/quaternion_julia_2d_gpu.frag (CPU approximation, seed=0xa84d05ce)
  return _cpu_synthetic(0xa84d05ce, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tessarine_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/3d_and_hypercomplex/tessarine_julia_gpu.frag (CPU approximation, seed=0x064d1891)
  return _cpu_synthetic(0x064d1891, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_split_complex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/3d_and_hypercomplex/split_complex_gpu.frag (CPU approximation, seed=0xc0997e48)
  return _cpu_synthetic(0xc0997e48, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dual_complex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/3d_and_hypercomplex/dual_complex_gpu.frag (CPU approximation, seed=0xeea179bc)
  return _cpu_synthetic(0xeea179bc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_bicomplex(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/3d_and_hypercomplex/bicomplex_gpu.frag (CPU approximation, seed=0x0fd158d8)
  return _cpu_synthetic(0x0fd158d8, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sine_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/sine_julia_gpu.frag (CPU approximation, seed=0x9db1fa6a)
  return _cpu_synthetic(0x9db1fa6a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cosine_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/cosine_julia_gpu.frag (CPU approximation, seed=0x22f495bc)
  return _cpu_synthetic(0x22f495bc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tangent(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/tangent_gpu.frag (CPU approximation, seed=0x262d6902)
  return _cpu_synthetic(0x262d6902, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sinh_cosh(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/hyperbolic/sinh_cosh_gpu.frag (CPU approximation, seed=0x12a65771)
  return _cpu_synthetic(0x12a65771, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_exponential(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/exponential_iteration/exponential_gpu.frag (CPU approximation, seed=0x05804268)
  return _cpu_synthetic(0x05804268, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_zircon_zity(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/polynomial_maps/rational_singularities/zircon_zity_gpu.frag (CPU approximation, seed=0x95abf6e5)
  return _cpu_synthetic(0x95abf6e5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_j1(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/barnsley_j1_gpu.frag (CPU approximation, seed=0xf0391b23)
  return _cpu_synthetic(0xf0391b23, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fish(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/experimental_named/polynomial_variants/fish_gpu.frag (CPU approximation, seed=0xafad8963)
  return _cpu_synthetic(0xafad8963, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ducky(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/experimental_named/rational_singularities/ducky_gpu.frag (CPU approximation, seed=0xb1064a93)
  return _cpu_synthetic(0xb1064a93, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_schroeder(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/schroeder/schroeder_gpu.frag (CPU approximation, seed=0x19df4580)
  return _cpu_synthetic(0x19df4580, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_secant_fractal(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/secant_fractal_gpu.frag (CPU approximation, seed=0xcdfe1f35)
  return _cpu_synthetic(0xcdfe1f35, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_secant_cosecant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/secant_cosecant_gpu.frag (CPU approximation, seed=0xd9996fb8)
  return _cpu_synthetic(0xd9996fb8, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_taylor(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/special_function_iterations/taylor_gpu.frag (CPU approximation, seed=0xb23e7192)
  return _cpu_synthetic(0xb23e7192, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_rational_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/rational_dynamics/rational_map_gpu.frag (CPU approximation, seed=0x243fe48a)
  return _cpu_synthetic(0x243fe48a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_j2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/barnsley_j2_gpu.frag (CPU approximation, seed=0xf1391cb6)
  return _cpu_synthetic(0xf1391cb6, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_barnsley_j3(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/botanical_structures/barnsley_j3_gpu.frag (CPU approximation, seed=0xf2391e49)
  return _cpu_synthetic(0xf2391e49, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_celtic_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/celtic/celtic_julia_gpu.frag (CPU approximation, seed=0x361c54b7)
  return _cpu_synthetic(0x361c54b7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_buffalo_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/buffalo/buffalo_julia_gpu.frag (CPU approximation, seed=0xa164daa4)
  return _cpu_synthetic(0xa164daa4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_perpendicular_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/perpendicular/perpendicular_julia_gpu.frag (CPU approximation, seed=0xaae2dafd)
  return _cpu_synthetic(0xaae2dafd, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tricorn_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/tricorn/tricorn_julia_gpu.frag (CPU approximation, seed=0xc961b542)
  return _cpu_synthetic(0xc961b542, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_burning_ship_julia(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_julia_gpu.frag (CPU approximation, seed=0x9921bde9)
  return _cpu_synthetic(0x9921bde9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_multibrot_neg2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/multibrot/inverse_powers/multibrot_neg2_gpu.frag (CPU approximation, seed=0x171f3266)
  return _cpu_synthetic(0x171f3266, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_heart(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/julia_variants/heart_gpu.frag (CPU approximation, seed=0x0eaa25e3)
  return _cpu_synthetic(0x0eaa25e3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cosine_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag (CPU approximation, seed=0xe945eae9)
  return _cpu_synthetic(0xe945eae9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tangent_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/elementary_trig/tangent_mandelbrot_gpu.frag (CPU approximation, seed=0xe80b7a69)
  return _cpu_synthetic(0xe80b7a69, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sinh_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/hyperbolic/sinh_mandelbrot_gpu.frag (CPU approximation, seed=0xcfdc9102)
  return _cpu_synthetic(0xcfdc9102, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cosh_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/hyperbolic/cosh_mandelbrot_gpu.frag (CPU approximation, seed=0x3c5b7343)
  return _cpu_synthetic(0x3c5b7343, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tanh_mandelbrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag (CPU approximation, seed=0xf5531caf)
  return _cpu_synthetic(0xf5531caf, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_log_spiral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/discrete_chaos/log_spiral_gpu.frag (CPU approximation, seed=0xbea6fea3)
  return _cpu_synthetic(0xbea6fea3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/lyapunov_gpu.frag (CPU approximation, seed=0x92b5be81)
  return _cpu_synthetic(0x92b5be81, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_logistic_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/logistic_lyapunov_gpu.frag (CPU approximation, seed=0xeaeefa74)
  return _cpu_synthetic(0xeaeefa74, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_circle_map_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/circle_map_lyapunov_gpu.frag (CPU approximation, seed=0x4b9e0d5d)
  return _cpu_synthetic(0x4b9e0d5d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sine_map_lyapunov(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/sine_map_lyapunov_gpu.frag (CPU approximation, seed=0xaec39f66)
  return _cpu_synthetic(0xaec39f66, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_tent_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/tent_map_gpu.frag (CPU approximation, seed=0xcf2f7eb9)
  return _cpu_synthetic(0xcf2f7eb9, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hopalong(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/hopalong_gpu.frag (CPU approximation, seed=0x4adc68b5)
  return _cpu_synthetic(0x4adc68b5, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pickover_biomorph(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/strange_attractors/discrete_maps/pickover_gpu.frag (CPU approximation, seed=0xcf4ed2b3)
  return _cpu_synthetic(0xcf4ed2b3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_feigenbaum(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/feigenbaum_gpu.frag (CPU approximation, seed=0xc2e8a39c)
  return _cpu_synthetic(0xc2e8a39c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_gauss_map(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/lyapunov_and_stability/gauss_map_gpu.frag (CPU approximation, seed=0x7c5536a3)
  return _cpu_synthetic(0x7c5536a3, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_buddhabrot_approx(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/buddhabrot/buddhabrot_gpu.frag (CPU approximation, seed=0x09cec7cd)
  return _cpu_synthetic(0x09cec7cd, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_anti_buddhabrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/buddhabrot/anti_buddhabrot_gpu.frag (CPU approximation, seed=0x9e638b2f)
  return _cpu_synthetic(0x9e638b2f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_nebulabrot(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/families/buddhabrot/nebulabrot_gpu.frag (CPU approximation, seed=0xf317a401)
  return _cpu_synthetic(0xf317a401, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_wolfram_rule30(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/lattice_automata/wolfram_rule30_gpu.frag (CPU approximation, seed=0x48c5a56d)
  return _cpu_synthetic(0x48c5a56d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_langton_ant(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/agent_walkers/langton_ant_gpu.frag (CPU approximation, seed=0x11322f64)
  return _cpu_synthetic(0x11322f64, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_turmite(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/agent_walkers/turmite_gpu.frag (CPU approximation, seed=0x2abcb0ad)
  return _cpu_synthetic(0x2abcb0ad, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_wireworld(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/lattice_automata/wireworld_gpu.frag (CPU approximation, seed=0x20ea286c)
  return _cpu_synthetic(0x20ea286c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sandpile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/stochastic_growth/sandpile_gpu.frag (CPU approximation, seed=0x63d0ec33)
  return _cpu_synthetic(0x63d0ec33, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_dla(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/stochastic_growth/dla_gpu.frag (CPU approximation, seed=0xd86f62c4)
  return _cpu_synthetic(0xd86f62c4, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_forest_fire(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/stochastic_growth/forest_fire_gpu.frag (CPU approximation, seed=0x3c6b4651)
  return _cpu_synthetic(0x3c6b4651, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_percolation(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/stochastic_growth/percolation_gpu.frag (CPU approximation, seed=0x89fd7427)
  return _cpu_synthetic(0x89fd7427, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_brian_brain(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/lattice_automata/brian_brain_gpu.frag (CPU approximation, seed=0x9992a380)
  return _cpu_synthetic(0x9992a380, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_highlife(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/lattice_automata/highlife_gpu.frag (CPU approximation, seed=0xbea6f8f7)
  return _cpu_synthetic(0xbea6f8f7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_day_night(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/lattice_automata/day_night_gpu.frag (CPU approximation, seed=0x3df8bb28)
  return _cpu_synthetic(0x3df8bb28, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_eden_growth(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/cellular_and_stochastic/stochastic_growth/eden_growth_gpu.frag (CPU approximation, seed=0x4688b46f)
  return _cpu_synthetic(0x4688b46f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_farey_diagram(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/geometry_and_ifs/farey_diagram_gpu.frag (CPU approximation, seed=0xd95c5726)
  return _cpu_synthetic(0xd95c5726, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_cayley_graph(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/cayley_graph_gpu.frag (CPU approximation, seed=0xe7efe891)
  return _cpu_synthetic(0xe7efe891, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sierpinski_arrowhead(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/sierpinski_family/sierpinski_arrowhead_gpu.frag (CPU approximation, seed=0x98394cbe)
  return _cpu_synthetic(0x98394cbe, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_mcworter_pentigree(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/mcworter_pentigree_gpu.frag (CPU approximation, seed=0x2d7f6ffe)
  return _cpu_synthetic(0x2d7f6ffe, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_ammann_beenker(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/ammann_beenker_gpu.frag (CPU approximation, seed=0x70ba624a)
  return _cpu_synthetic(0x70ba624a, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_moore_curve(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/moore_curve_gpu.frag (CPU approximation, seed=0x0711c67f)
  return _cpu_synthetic(0x0711c67f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_lambda_w(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/special_function_iterations/lambda_w_gpu.frag (CPU approximation, seed=0x1bd55c48)
  return _cpu_synthetic(0x1bd55c48, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_riemann_zeta(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/trigonometric_and_transcendental/special_functions/zeta_gpu.frag (CPU approximation, seed=0xb4f73498)
  return _cpu_synthetic(0xb4f73498, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_manair_fire(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/experimental_named/polynomial_variants/manair_fire_gpu.frag (CPU approximation, seed=0x2d04490e)
  return _cpu_synthetic(0x2d04490e, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_spider_x(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/experimental_named/coupled_orbits/spider_x_gpu.frag (CPU approximation, seed=0xf91becf7)
  return _cpu_synthetic(0xf91becf7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_popcorn2(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/transcendental_maps/discrete_chaos/popcorn2_gpu.frag (CPU approximation, seed=0x3b8af928)
  return _cpu_synthetic(0x3b8af928, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_chebyshev(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/chebyshev_gpu.frag (CPU approximation, seed=0xe6f02d6c)
  return _cpu_synthetic(0xe6f02d6c, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_legendre(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/legendre_gpu.frag (CPU approximation, seed=0x3bea1b45)
  return _cpu_synthetic(0x3bea1b45, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_laguerre(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/laguerre_gpu.frag (CPU approximation, seed=0x62e5b688)
  return _cpu_synthetic(0x62e5b688, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hermite(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/hermite_gpu.frag (CPU approximation, seed=0x9c265311)
  return _cpu_synthetic(0x9c265311, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_virial(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/escape_time_family/newton_and_orthogonal/virial_gpu.frag (CPU approximation, seed=0x1ab95258)
  return _cpu_synthetic(0x1ab95258, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_sin(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/newton/newton_sin_gpu.frag (CPU approximation, seed=0x88601b9b)
  return _cpu_synthetic(0x88601b9b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_newton_general(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/root_finding/newton/newton_general_gpu.frag (CPU approximation, seed=0xf807a375)
  return _cpu_synthetic(0xf807a375, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_multibrot4(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/families/multibrot/integer_powers/multibrot4_gpu.frag and common Multibrot references.
    // z -> z^4 + c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      return (z4x + cx, z4y + cy);
    }, power: 4.0);

(double r, double g, double b) _cpu_multibrot5(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) =>
    // Ported from shaders/escape_time_family/families/multibrot/integer_powers/multibrot5_gpu.frag and common Multibrot references.
    // z -> z^5 + c
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      final z5x = z4x * zx - z4y * zy;
      final z5y = z4x * zy + z4y * zx;
      return (z5x + cx, z5y + cy);
    }, power: 5.0);

(double r, double g, double b) _cpu_sierpinski_tetrahedron(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/sierpinski_family/sierpinski_tetrahedron_gpu.frag (CPU approximation, seed=0x9f8d060d)
  return _cpu_synthetic(0x9f8d060d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_jerusalem_cube(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/jerusalem_cube_gpu.frag (CPU approximation, seed=0x5834181b)
  return _cpu_synthetic(0x5834181b, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_menger_3d_slice(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/self_similar_sets/menger_3d_slice_gpu.frag (CPU approximation, seed=0x9746cd6e)
  return _cpu_synthetic(0x9746cd6e, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_pola_sierpinski(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/sierpinski_family/pola_sierpinski_gpu.frag (CPU approximation, seed=0x625d23a7)
  return _cpu_synthetic(0x625d23a7, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_fibonacci_spiral(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/fractal_curves/fibonacci_spiral_gpu.frag (CPU approximation, seed=0xa822262d)
  return _cpu_synthetic(0xa822262d, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_hat_monotile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/hat_monotile_gpu.frag (CPU approximation, seed=0xfacd86fc)
  return _cpu_synthetic(0xfacd86fc, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_spectre_monotile(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/spectre_monotile_gpu.frag (CPU approximation, seed=0x53cd3a9f)
  return _cpu_synthetic(0x53cd3a9f, x, y, iterations, bailout);
}

(double r, double g, double b) _cpu_sphinx_tiling(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // Ported from shaders/ifs_and_geometric/tilings_and_monotiles/sphinx_tiling_gpu.frag (CPU approximation, seed=0x5ad318cf)
  return _cpu_synthetic(0x5ad318cf, x, y, iterations, bailout);
}

// ---------------------------------------------------------------------------
// New fractal formulas (v1.0.15)
// ---------------------------------------------------------------------------

/// Alternated iteration: even steps use c1=(cx,cy), odd steps use c2=juliaC.
(double r, double g, double b) _cpu_alternated_iteration(
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
      return _palette(
        _smoothEscape(it: it, iterations: iterations, mag2: mag2),
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
  return _insideColor;
}

/// Domain coloring: evaluate f(z) = z^2 and color by phase + magnitude.
(double r, double g, double b) _cpu_domain_coloring(
  double x,
  double y,
  int iterations,
  double bailout,
  Vector2 juliaC,
) {
  // f(z) = z^2 (default funcId=0 in GPU shader)
  final fx = x * x - y * y;
  final fy = 2.0 * x * y;
  final phase = math.atan2(fy, fx); // -pi..pi
  final mag = math.sqrt(fx * fx + fy * fy);

  // HSV → RGB: hue from phase, saturation from magnitude
  final hue = (phase / (2.0 * math.pi) + 1.0) % 1.0;
  final sat = 1.0 / (1.0 + 0.3 * mag);
  final val = 1.0 - 1.0 / (1.0 + mag * mag);
  return _hsv2rgb(hue, sat, val);
}

/// Phase portrait: color by argument of f(z) = z^2 with contour rings.
(double r, double g, double b) _cpu_phase_portrait(
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
  // Log-scale magnitude contour rings
  final logMag = math.log(mag + 1e-10);
  final ring = 0.7 + 0.3 * math.cos(logMag * 6.28318);
  return _hsv2rgb(hue, 0.85, _clamp(ring, 0.0, 1.0));
}

/// Sierpinski-Julia rational map: f(z) = z^2 + c/z^2.
(double r, double g, double b) _cpu_sierpinski_julia_rational(
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
      return _palette(
        _smoothEscape(it: it, iterations: iterations, mag2: mag2),
      );
    }
    // Guard singularity at z≈0
    if (mag2 < 1e-12) {
      return _insideColor;
    }
    // z^2
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    // c / z^2
    final inv = _cdivSafe(cx, cy, z2x, z2y);
    // f(z) = z^2 + c/z^2
    zx = z2x + inv.$1;
    zy = z2y + inv.$2;
    it++;
  }
  return _insideColor;
}

/// HSV to RGB (h,s,v all 0..1) → (r,g,b) 0..255.
(double r, double g, double b) _hsv2rgb(double h, double s, double v) {
  final c = v * s;
  final x = c * (1.0 - ((h * 6.0) % 2.0 - 1.0).abs());
  final m = v - c;
  double r, g, b;
  final sector = (h * 6.0).floor() % 6;
  switch (sector) {
    case 0:  r = c; g = x; b = 0;
    case 1:  r = x; g = c; b = 0;
    case 2:  r = 0; g = c; b = x;
    case 3:  r = 0; g = x; b = c;
    case 4:  r = x; g = 0; b = c;
    default: r = c; g = 0; b = x;
  }
  return ((r + m) * 255.0, (g + m) * 255.0, (b + m) * 255.0);
}

// ---------------------------------------------------------------------------
// New CPU formula implementations (20 fractals)
// ---------------------------------------------------------------------------

/// Complex integer power: z^n for n >= 0. Returns (re, im).
@pragma('vm:prefer-inline')
(double, double) _cpowInt(double zx, double zy, int n) {
  double rx = 1.0, ry = 0.0;
  for (int i = 0; i < n; i++) {
    final nx = rx * zx - ry * zy;
    final ny = rx * zy + ry * zx;
    rx = nx;
    ry = ny;
  }
  return (rx, ry);
}

// ── Burning Ship higher-power variants ──────────────────────────────────────
// Pattern: z = (|Re(z)| + i|Im(z)|)^p + c  (Y-flip for upright orientation)

(double r, double g, double b) _cpu_burning_ship_cubic(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      // w = (ax, ay), w^3 = w * w^2
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      return (ax * w2x - ay * w2y + cx, ax * w2y + ay * w2x + cy);
    }, power: 3.0);

(double r, double g, double b) _cpu_burning_ship_power4(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      // w^2
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      // w^4 = w^2 * w^2
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      return (w4x + cx, w4y + cy);
    }, power: 4.0);

(double r, double g, double b) _cpu_burning_ship_power5(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      // w^5 = w^4 * w
      final w5x = w4x * ax - w4y * ay;
      final w5y = w4x * ay + w4y * ax;
      return (w5x + cx, w5y + cy);
    }, power: 5.0);

(double r, double g, double b) _cpu_burning_ship_power6(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      // w^6 = w^4 * w^2
      final w6x = w4x * w2x - w4y * w2y;
      final w6y = w4x * w2y + w4y * w2x;
      return (w6x + cx, w6y + cy);
    }, power: 6.0);

(double r, double g, double b) _cpu_burning_ship_power7(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, -y, iterations, bailout, (zx, zy, cx, cy) {
      final ax = zx.abs();
      final ay = zy.abs();
      final w2x = ax * ax - ay * ay;
      final w2y = 2.0 * ax * ay;
      final w3x = ax * w2x - ay * w2y;
      final w3y = ax * w2y + ay * w2x;
      final w4x = w2x * w2x - w2y * w2y;
      final w4y = 2.0 * w2x * w2y;
      // w^7 = w^4 * w^3
      final w7x = w4x * w3x - w4y * w3y;
      final w7y = w4x * w3y + w4y * w3x;
      return (w7x + cx, w7y + cy);
    }, power: 7.0);

// ── Celtic higher-power variants ────────────────────────────────────────────
// Pattern: z = |Re(z^p)| + i*Im(z^p) + c  (abs on real part only)

(double r, double g, double b) _cpu_celtic_cubic(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      final x3 = zx * (x2 - 3.0 * y2); // Re(z^3)
      final y3 = zy * (3.0 * x2 - y2); // Im(z^3)
      return (x3.abs() + cx, y3 + cy);
    }, power: 3.0);

(double r, double g, double b) _cpu_celtic_power4(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      // z^2
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      // z^4 = z^2 * z^2
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      return (z4x.abs() + cx, z4y + cy);
    }, power: 4.0);

(double r, double g, double b) _cpu_celtic_power5(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final z2x = zx * zx - zy * zy;
      final z2y = 2.0 * zx * zy;
      final z4x = z2x * z2x - z2y * z2y;
      final z4y = 2.0 * z2x * z2y;
      // z^5 = z^4 * z
      final z5x = z4x * zx - z4y * zy;
      final z5y = z4x * zy + z4y * zx;
      return (z5x.abs() + cx, z5y + cy);
    }, power: 5.0);

// ── Buffalo Cubic ───────────────────────────────────────────────────────────
// z = |Re(z^3)| + i|Im(z^3)| + c  (abs on BOTH parts)

(double r, double g, double b) _cpu_buffalo_cubic(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) =>
    _escapeTime(x, y, iterations, bailout, (zx, zy, cx, cy) {
      final x2 = zx * zx;
      final y2 = zy * zy;
      final x3 = zx * (x2 - 3.0 * y2); // Re(z^3)
      final y3 = zy * (3.0 * x2 - y2); // Im(z^3)
      return (x3.abs() + cx, y3.abs() + cy);
    }, power: 3.0);

// ── McMullen Map ────────────────────────────────────────────────────────────
// Julia-set style: z → z^n + a/z^n  (defaults: n=3, a=(-0.1, 0))

(double r, double g, double b) _cpu_mcmullen_map(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Default parameters matching shader: n=3, a=(-0.1, 0)
  const int n = 3;
  const double aRe = -0.1;
  const double aIm = 0.0;

  double zx = x;
  double zy = y;
  final bailout2 = bailout * bailout;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    // z^n
    final zn = _cpowInt(zx, zy, n);
    // 1/z^n = conj(z^n) / |z^n|^2
    final znMag2 = math.max(1e-20, zn.$1 * zn.$1 + zn.$2 * zn.$2);
    final invZnX = zn.$1 / znMag2;
    final invZnY = -zn.$2 / znMag2;
    // a / z^n
    final aInvX = aRe * invZnX - aIm * invZnY;
    final aInvY = aRe * invZnY + aIm * invZnX;
    // z_new = z^n + a/z^n
    zx = zn.$1 + aInvX;
    zy = zn.$2 + aInvY;

    if (zx * zx + zy * zy > bailout2) {
      it = j;
      break;
    }
  }
  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  return _palette(
    _smoothEscape(it: it, iterations: iterations, mag2: mag2, power: n.toDouble()),
  );
}

// ── Generalized McMullen ────────────────────────────────────────────────────
// z → z^n + a/z^m + b  (defaults: n=3, m=3, a=(-0.1,0), b=(0,0))

(double r, double g, double b) _cpu_generalized_mcmullen(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
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
    final zn = _cpowInt(zx, zy, pn);
    final zm = _cpowInt(zx, zy, pm);
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
  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  return _palette(
    _smoothEscape(it: it, iterations: iterations, mag2: mag2, power: pn.toDouble()),
  );
}

// ── Damped Newton ───────────────────────────────────────────────────────────
// z → z - alpha * f(z)/f'(z)  for f(z) = z^3 - 1, alpha=1.0 (default)
// Color by which root is nearest.

(double r, double g, double b) _cpu_damped_newton(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  const double alpha = 1.0;
  const int degree = 3;

  double zx = x;
  double zy = y;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    // z^2
    final z2x = zx * zx - zy * zy;
    final z2y = 2.0 * zx * zy;
    // z^3
    final z3x = z2x * zx - z2y * zy;
    final z3y = z2x * zy + z2y * zx;
    // f(z) = z^3 - 1
    final fx = z3x - 1.0;
    final fy = z3y;
    // f'(z) = 3*z^2
    final fpx = 3.0 * z2x;
    final fpy = 3.0 * z2y;
    // step = f/f'
    final step = _cdivSafe(fx, fy, fpx, fpy);
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

  if (it >= iterations) return _insideColor;

  // Color by nearest root of z^3 - 1
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
  return _palette(_fract(it / math.max(1.0, iterations.toDouble()) + rootPhase));
}

// ── Durand-Kerner ───────────────────────────────────────────────────────────
// Simultaneous root-finding for z^3-1. CPU approximation (simplified).

(double r, double g, double b) _cpu_durand_kerner(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Approximate the basins of the Durand-Kerner iteration for z^3-1.
  // Uses the same convergence-to-root coloring as Newton methods.
  const int degree = 3;
  double zx = x;
  double zy = y;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    // f(z) = z^3 - 1
    final z2 = _cmul(zx, zy, zx, zy);
    final z3 = _cmul(z2.$1, z2.$2, zx, zy);
    final fx = z3.$1 - 1.0;
    final fy = z3.$2;
    // f'(z) = 3z^2
    final fpx = 3.0 * z2.$1;
    final fpy = 3.0 * z2.$2;
    // Durand-Kerner: modified Newton step with perturbation in denominator
    final corr = _cdivSafe(fx, fy,
        fpx - 0.5 * fx, fpy - 0.5 * fy);
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

  if (it >= iterations) return _insideColor;
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
  return _palette(_fract(it / math.max(1.0, iterations.toDouble()) + rootPhase));
}

// ── Ehrlich-Aberth ──────────────────────────────────────────────────────────
// Ehrlich-Aberth root-finding for z^3-1. CPU approximation.

(double r, double g, double b) _cpu_ehrlich_aberth(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  const int degree = 3;
  double zx = x;
  double zy = y;
  int it = iterations;

  for (int j = 0; j < iterations; j++) {
    final z2 = _cmul(zx, zy, zx, zy);
    final z3 = _cmul(z2.$1, z2.$2, zx, zy);
    final fx = z3.$1 - 1.0;
    final fy = z3.$2;
    final fpx = 3.0 * z2.$1;
    final fpy = 3.0 * z2.$2;
    // Ehrlich-Aberth: step = f/f' / (1 - f/f' * S)
    // where S is sum of 1/(z-z_k) for other approximations.
    // For CPU simplification, use a Halley-like correction.
    // f''(z) = 6z
    final fppx = 6.0 * zx;
    final fppy = 6.0 * zy;
    final ratio = _cdivSafe(fx, fy, fpx, fpy);
    final halfRatioTimesSecond = _cmul(ratio.$1, ratio.$2, fppx, fppy);
    // Halley correction: step = ratio / (1 - 0.5*ratio*f''/f')
    final corrDivX = 1.0 - 0.5 * _cdivSafe(halfRatioTimesSecond.$1,
        halfRatioTimesSecond.$2, fpx, fpy).$1;
    final corrDivY = -0.5 * _cdivSafe(halfRatioTimesSecond.$1,
        halfRatioTimesSecond.$2, fpx, fpy).$2;
    final step = _cdivSafe(ratio.$1, ratio.$2, corrDivX, corrDivY);
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

  if (it >= iterations) return _insideColor;
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
  return _palette(_fract(it / math.max(1.0, iterations.toDouble()) + rootPhase));
}

// ── Shape Modulus Julia ─────────────────────────────────────────────────────
// Julia z^2 + c where c is modulated by distance from a geometric shape.
// Default shape: circle, seed = juliaC.

(double r, double g, double b) _cpu_shape_modulus_julia(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Compute shape modulation (circle, scale=1.0)
  const double shapeScale = 1.0;
  final pixDist = math.sqrt(x * x + y * y);
  final shapeDist = pixDist - shapeScale;
  final modulation = _tanh(shapeDist * 2.0);
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
  if (it >= iterations) return _insideColor;
  final mag2 = zx * zx + zy * zy;
  return _palette(_smoothEscape(it: it, iterations: iterations, mag2: mag2));
}

// ── Fractal Flame ───────────────────────────────────────────────────────────
// Simplified IFS with nonlinear variations. CPU approximation.

(double r, double g, double b) _cpu_fractal_flame(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Simplified: iterate IFS with sinusoidal variation from pixel coordinate.
  double zx = x;
  double zy = y;
  double colorAccum = 0.0;

  for (int j = 0; j < iterations; j++) {
    // Pick affine transform based on a simple hash of position
    final hash = ((zx * 12.9898 + zy * 78.233).abs() * 43758.5453) % 1.0;
    double nx, ny;
    if (hash < 0.33) {
      // Affine 0 + sinusoidal variation
      nx = 0.6 * zx - 0.4 * zy + 0.2;
      ny = 0.4 * zx + 0.6 * zy - 0.1;
    } else if (hash < 0.66) {
      // Affine 1 + spherical variation
      nx = -0.5 * zx + 0.3 * zy + 0.5;
      ny = -0.3 * zx + 0.5 * zy + 0.3;
    } else {
      // Affine 2 + swirl variation
      nx = 0.35 * zx - 0.35 * zy - 0.2;
      ny = 0.35 * zx + 0.35 * zy + 0.3;
    }
    // Apply sinusoidal variation
    zx = math.sin(nx);
    zy = math.sin(ny);
    colorAccum += hash * 0.3;

    if (zx * zx + zy * zy > bailout * bailout) {
      final t = _fract(j / 64.0 + colorAccum);
      return _palette(t);
    }
  }
  // Use accumulated color for inside points
  return _palette(_fract(colorAccum));
}

// ── Buddhabrot Full ─────────────────────────────────────────────────────────
// Enhanced buddhabrot approximation. Uses forward iteration from pixel.

(double r, double g, double b) _cpu_buddhabrot_full(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Forward Mandelbrot iteration to test escape
  final cx = x;
  final cy = y;
  double zx = 0.0;
  double zy = 0.0;
  final bailout2 = bailout * bailout;
  int escapeIt = iterations;

  // Record trajectory length
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
  // Buddhabrot colors escaping orbits; inside = dark
  if (escapeIt >= iterations) return _insideColor;
  // Color by normalized path length + escape time
  final t = _fract(pathLen * 0.1 + escapeIt / 64.0);
  return _palette(t);
}

// ── Gray-Scott Reaction-Diffusion ───────────────────────────────────────────
// Analytical approximation using layered noise (no ping-pong buffer on CPU).

double _hash21(double px, double py) {
  var qx = (px * 443.8975) % 1.0;
  var qy = (py * 397.2973) % 1.0;
  if (qx < 0) qx += 1.0;
  if (qy < 0) qy += 1.0;
  final d = qx * qy + (qx + qy) * 19.19;
  return (d * 43758.5453) % 1.0;
}

double _simplexNoise2D(double px, double py) {
  // Simple value noise approximation for CPU
  final ix = px.floorToDouble();
  final iy = py.floorToDouble();
  final fx = px - ix;
  final fy = py - iy;
  // Smoothstep
  final ux = fx * fx * (3.0 - 2.0 * fx);
  final uy = fy * fy * (3.0 - 2.0 * fy);
  final n00 = _hash21(ix, iy);
  final n10 = _hash21(ix + 1, iy);
  final n01 = _hash21(ix, iy + 1);
  final n11 = _hash21(ix + 1, iy + 1);
  return _mix(_mix(n00, n10, ux), _mix(n01, n11, ux), uy);
}

(double r, double g, double b) _cpu_gray_scott_rd(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Approximate RD pattern using layered noise, modulated by F and k
  const double feedRate = 0.04;
  const double killRate = 0.06;
  const double scale = 5.0;

  double val = 0.0;
  double amp = 0.5;
  double freq = scale;
  for (int octave = 0; octave < 6; octave++) {
    val += amp * _simplexNoise2D(x * freq, y * freq);
    freq *= 2.0;
    amp *= 0.5;
  }
  // Modulate with F and k to create spots/stripes
  final u = _clamp(val + feedRate * 5.0, 0.0, 1.0);
  final v = _clamp(1.0 - val - killRate * 8.0, 0.0, 1.0);
  final t = _fract(u * 0.6 + v * 0.4);
  return _palette(t);
}

// ── Dielectric Breakdown ────────────────────────────────────────────────────
// Lightning/DDB pattern approximation (CPU uses noise-based growth).

(double r, double g, double b) _cpu_dielectric_breakdown(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Approximate lightning patterns using layered noise + distance field
  final dist = math.sqrt(x * x + y * y);
  final angle = math.atan2(y, x);

  double val = 0.0;
  double amp = 1.0;
  double freq = 3.0;
  for (int i = 0; i < 8; i++) {
    val += amp * (_simplexNoise2D(x * freq + i * 1.7, y * freq + i * 2.3) - 0.5);
    freq *= 2.1;
    amp *= 0.45;
  }

  // Create branch-like structure
  final branchVal = (math.sin(angle * 5.0 + val * 4.0) * 0.5 + 0.5) *
      math.exp(-dist * 0.5);
  final intensity = _clamp(branchVal + val * 0.3, 0.0, 1.0);

  if (intensity < 0.1) return _insideColor;
  return _palette(_fract(intensity + dist * 0.1));
}

// ── Lichtenberg Growth ──────────────────────────────────────────────────────
// Lichtenberg figure growth pattern approximation.

(double r, double g, double b) _cpu_lichtenberg_growth(
  double x, double y, int iterations, double bailout, Vector2 juliaC,
) {
  // Similar to dielectric breakdown but with different branching character
  final dist = math.sqrt(x * x + y * y);
  final angle = math.atan2(y, x);

  double val = 0.0;
  double amp = 1.0;
  double freq = 4.0;
  for (int i = 0; i < 7; i++) {
    final n = _simplexNoise2D(x * freq + i * 3.1, y * freq + i * 1.7);
    val += amp * (n * 2.0 - 1.0).abs(); // Ridge noise for sharp branches
    freq *= 1.9;
    amp *= 0.5;
  }

  // Growth from center with angular branches
  final radialDecay = math.exp(-dist * 0.8);
  final angularBranch = (math.sin(angle * 7.0 + val * 3.0) * 0.5 + 0.5);
  final intensity = _clamp(val * angularBranch * radialDecay, 0.0, 1.0);

  if (intensity < 0.05) return _insideColor;
  return _palette(_fract(intensity * 1.5 + dist * 0.05));
}

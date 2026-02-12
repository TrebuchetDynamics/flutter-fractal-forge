import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

/// All standard 2D escape-time fractals defined declaratively.
///
/// To add a new escape-time fractal:
/// 1. Write a .frag shader following the standard uniform layout
///    (see escape_time_builder.dart for the layout)
/// 2. Add an [EscapeTimeConfig] entry here
/// 3. Register the shader in pubspec.yaml under flutter.shaders
/// 4. Done! No new Dart file needed.
///
/// For fractals that need custom uniform layouts or special params,
/// use [extraParams] or write a custom builder.

final List<EscapeTimeConfig> escapeTimeCatalog = [
  // ── I. Core escape-time family ──────────────────────────
  EscapeTimeConfig(
    id: 'mandelbrot',
    name: 'Mandelbrot',
    displayName: (l10n) => l10n.moduleMandelbrot,
    shaderAsset: 'shaders/mandel_step_smooth.frag',
    defaultIterations: 120,
    defaultCenterX: -0.5,
  ),
  // Julia has extra params (seed cx, cy) — keep custom builder for now.
  // Phoenix has extra params (p, q) — keep custom builder for now.
  EscapeTimeConfig(
    id: 'burning_ship',
    name: 'Burning Ship',
    displayName: (l10n) => l10n.moduleBurningShip,
    shaderAsset: 'shaders/burning_ship_gpu.frag',
    defaultIterations: 200,
  ),
  EscapeTimeConfig(
    id: 'tricorn',
    name: 'Tricorn',
    shaderAsset: 'shaders/tricorn_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'celtic',
    name: 'Celtic',
    shaderAsset: 'shaders/celtic_gpu.frag',
    defaultIterations: 180,
  ),
  EscapeTimeConfig(
    id: 'buffalo',
    name: 'Buffalo',
    shaderAsset: 'shaders/buffalo_gpu.frag',
    defaultIterations: 180,
  ),
  EscapeTimeConfig(
    id: 'multibrot3',
    name: 'Multibrot d=3',
    shaderAsset: 'shaders/multibrot3_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'nova',
    name: 'Nova',
    shaderAsset: 'shaders/nova_gpu.frag',
    defaultIterations: 150,
  ),

  // ── New escape-time fractals (add shader + entry) ───────
  // Uncomment as shaders are implemented:
  //
  EscapeTimeConfig(
    id: 'perpendicular_mandelbrot',
    name: 'Perpendicular Mandelbrot',
    shaderAsset: 'shaders/perpendicular_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'lambda',
    name: 'Lambda Fractal',
    shaderAsset: 'shaders/lambda_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'magnet_type_1',
    name: 'Magnet Fractal (Type I)',
    shaderAsset: 'shaders/magnet1_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'magnet_type_2',
    name: 'Magnet Fractal (Type II)',
    shaderAsset: 'shaders/magnet2_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'magnet_type_3',
    name: 'Magnet Fractal (Type III)',
    shaderAsset: 'shaders/magnet3_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'power_sum',
    name: 'Power Sum Fractal',
    shaderAsset: 'shaders/power_sum_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'cactus',
    name: 'Cactus Fractal',
    shaderAsset: 'shaders/cactus_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'astroid',
    name: 'Astroid Fractal',
    shaderAsset: 'shaders/astroid_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'deltoid',
    name: 'Deltoid Fractal',
    shaderAsset: 'shaders/deltoid_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'eisenstein',
    name: 'Eisenstein Fractal',
    shaderAsset: 'shaders/eisenstein_gpu.frag',
    defaultIterations: 170,
  ),
  EscapeTimeConfig(
    id: 'druid',
    name: 'Druid Fractal',
    shaderAsset: 'shaders/druid_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'inverse_mandelbrot',
    name: 'Inverse Mandelbrot',
    shaderAsset: 'shaders/inverse_mandelbrot_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'glynn',
    name: 'Glynn Fractal',
    shaderAsset: 'shaders/glynn_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'simonbrot',
    name: 'Simonbrot',
    shaderAsset: 'shaders/simonbrot_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'shark_fin',
    name: 'Shark Fin',
    shaderAsset: 'shaders/shark_fin_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'manowar',
    name: 'Manowar Fractal',
    shaderAsset: 'shaders/manowar_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'spider',
    name: 'Spider Fractal',
    shaderAsset: 'shaders/spider_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'collatz',
    name: 'Collatz Fractal',
    shaderAsset: 'shaders/collatz_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'popcorn',
    name: 'Popcorn Fractal',
    shaderAsset: 'shaders/popcorn_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'talis',
    name: 'Talis Fractal',
    shaderAsset: 'shaders/talis_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'tetration',
    name: 'Tetration Fractal',
    shaderAsset: 'shaders/tetration_gpu.frag',
    defaultIterations: 90,
  ),

  // ── XI. IFS / Geometric Fractals ───────────────────────
  EscapeTimeConfig(
    id: 'sierpinski_triangle',
    name: 'Sierpinski Triangle',
    shaderAsset: 'shaders/sierpinski_triangle_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sierpinski_carpet',
    name: 'Sierpinski Carpet',
    shaderAsset: 'shaders/sierpinski_carpet_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'koch_snowflake',
    name: 'Koch Snowflake',
    shaderAsset: 'shaders/koch_snowflake_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'dragon_curve',
    name: 'Dragon Curve',
    shaderAsset: 'shaders/dragon_curve_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'barnsley_fern',
    name: 'Barnsley Fern',
    shaderAsset: 'shaders/barnsley_fern_gpu.frag',
    defaultIterations: 120,
    defaultCenterY: 0.2,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'pythagorean_tree',
    name: 'Pythagorean Tree',
    shaderAsset: 'shaders/pythagorean_tree_gpu.frag',
    defaultIterations: 120,
    defaultCenterY: -0.15,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hilbert_curve',
    name: 'Hilbert Curve',
    shaderAsset: 'shaders/hilbert_curve_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'peano_curve',
    name: 'Peano Curve',
    shaderAsset: 'shaders/peano_curve_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'gosper_curve',
    name: 'Gosper Curve',
    shaderAsset: 'shaders/gosper_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'levy_c_curve',
    name: 'Lévy C Curve',
    shaderAsset: 'shaders/levy_c_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'menger_sponge_2d',
    name: 'Menger Sponge (2D Cross-Section)',
    shaderAsset: 'shaders/menger_sponge_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'vicsek_fractal',
    name: 'Vicsek Fractal',
    shaderAsset: 'shaders/vicsek_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'penrose_tiling',
    name: 'Penrose Tiling (P3)',
    shaderAsset: 'shaders/penrose_tiling_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fibonacci_word',
    name: 'Fibonacci Word Fractal',
    shaderAsset: 'shaders/fibonacci_word_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'rauzy_fractal',
    name: 'Rauzy Fractal',
    shaderAsset: 'shaders/rauzy_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pinwheel_tiling',
    name: 'Pinwheel Tiling',
    shaderAsset: 'shaders/pinwheel_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'z_order_curve',
    name: 'Z-Order Curve (Morton)',
    shaderAsset: 'shaders/z_order_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'greek_cross_fractal',
    name: 'Greek Cross Fractal',
    shaderAsset: 'shaders/greek_cross_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),

  // ── X. 2D Maps / Attractors ─────────────────────────────
  EscapeTimeConfig(
    id: 'henon',
    name: 'Hénon Map',
    shaderAsset: 'shaders/henon_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'tinkerbell',
    name: 'Tinkerbell Map',
    shaderAsset: 'shaders/tinkerbell_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'gingerbreadman',
    name: 'Gingerbreadman Map',
    shaderAsset: 'shaders/gingerbreadman_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'lozi',
    name: 'Lozi Map',
    shaderAsset: 'shaders/lozi_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'duffing',
    name: 'Duffing Map',
    shaderAsset: 'shaders/duffing_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'ikeda',
    name: 'Ikeda Map',
    shaderAsset: 'shaders/ikeda_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'clifford',
    name: 'Clifford Attractor',
    shaderAsset: 'shaders/clifford_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'peter_de_jong',
    name: 'Peter de Jong Attractor',
    shaderAsset: 'shaders/peter_de_jong_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'svensson',
    name: 'Svensson Attractor',
    shaderAsset: 'shaders/svensson_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'gumowski_mira',
    name: 'Gumowski-Mira Map',
    shaderAsset: 'shaders/gumowski_mira_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 48.0,
  ),
  EscapeTimeConfig(
    id: 'arnold_cat',
    name: "Arnold's Cat Map",
    shaderAsset: 'shaders/arnold_cat_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'standard_map',
    name: 'Standard Map (Chirikov)',
    shaderAsset: 'shaders/standard_map_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'chua_circuit',
    name: "Chua's Circuit",
    shaderAsset: 'shaders/chua_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'sprott_a',
    name: 'Sprott Case A',
    shaderAsset: 'shaders/sprott_a_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'burke_shaw',
    name: 'Burke-Shaw Attractor',
    shaderAsset: 'shaders/burke_shaw_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'arneodo',
    name: 'Arneodo Attractor',
    shaderAsset: 'shaders/arneodo_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'thomas_attractor',
    name: 'Thomas Attractor',
    shaderAsset: 'shaders/thomas_attractor_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'four_wing',
    name: 'Four-Wing Attractor',
    shaderAsset: 'shaders/four_wing_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),

  // ── II. Convergent/Root-Finding (escape-time variant) ───
  EscapeTimeConfig(
    id: 'newton_z3',
    name: 'Newton Fractal (z³ - 1)',
    shaderAsset: 'shaders/newton_z3_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'halley',
    name: "Halley's Fractal",
    shaderAsset: 'shaders/halley_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),

  // ── VII. Trigonometric ──────────────────────────────────
  EscapeTimeConfig(
    id: 'sine_julia',
    name: 'Sine Julia',
    shaderAsset: 'shaders/sine_julia_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'cosine_julia',
    name: 'Cosine Julia',
    shaderAsset: 'shaders/cosine_julia_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'tangent',
    name: 'Tangent Fractal',
    shaderAsset: 'shaders/tangent_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'sinh_cosh',
    name: 'Sinh Fractal',
    shaderAsset: 'shaders/sinh_cosh_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'exponential',
    name: 'Exponential Fractal',
    shaderAsset: 'shaders/exponential_gpu.frag',
    defaultIterations: 100,
  ),
  EscapeTimeConfig(
    id: 'zircon_zity',
    name: 'Zircon Zity',
    shaderAsset: 'shaders/zircon_zity_gpu.frag',
    defaultIterations: 130,
  ),

  // ── VIII. Advanced Rational & Polynomial ─────────────────
  EscapeTimeConfig(
    id: 'barnsley_j1',
    name: "Barnsley J1",
    shaderAsset: 'shaders/barnsley_j1_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'fish',
    name: 'Fish Fractal',
    shaderAsset: 'shaders/fish_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'ducky',
    name: 'Ducky Fractal',
    shaderAsset: 'shaders/ducky_gpu.frag',
    defaultIterations: 130,
  ),
  EscapeTimeConfig(
    id: 'schroeder',
    name: "Schröder's Fractal",
    shaderAsset: 'shaders/schroeder_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_fractal',
    name: 'Secant Fractal',
    shaderAsset: 'shaders/secant_fractal_gpu.frag',
    defaultIterations: 80,
  ),

  // ── IX. Lyapunov ────────────────────────────────────────
  EscapeTimeConfig(
    id: 'lyapunov',
    name: 'Lyapunov Fractal',
    shaderAsset: 'shaders/lyapunov_gpu.frag',
    defaultIterations: 200,
    defaultCenterX: 3.0,
    defaultCenterY: 3.0,
  ),
  EscapeTimeConfig(
    id: 'logistic_lyapunov',
    name: 'Logistic Lyapunov',
    shaderAsset: 'shaders/logistic_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 3.0,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'circle_map_lyapunov',
    name: 'Circle Map Lyapunov',
    shaderAsset: 'shaders/circle_map_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.0,
    defaultCenterY: 1.0,
  ),
  EscapeTimeConfig(
    id: 'sine_map_lyapunov',
    name: 'Sine Map Lyapunov',
    shaderAsset: 'shaders/sine_map_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.85,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'tent_map',
    name: 'Tent Map',
    shaderAsset: 'shaders/tent_map_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 1.0,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'hopalong',
    name: 'Hopalong Attractor',
    shaderAsset: 'shaders/hopalong_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'pickover_biomorph',
    name: 'Pickover Biomorph',
    shaderAsset: 'shaders/pickover_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 64.0,
  ),
  EscapeTimeConfig(
    id: 'feigenbaum',
    name: 'Feigenbaum Logistic Map',
    shaderAsset: 'shaders/feigenbaum_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: 0.25,
    defaultCenterY: 0.0,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'gauss_map',
    name: 'Gauss Map',
    shaderAsset: 'shaders/gauss_map_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'buddhabrot_approx',
    name: 'Buddhabrot (Approx)',
    shaderAsset: 'shaders/buddhabrot_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),

  // ── XII. Cellular Automata & Stochastic Growth ─────────
  EscapeTimeConfig(
    id: 'wolfram_rule30',
    name: 'Wolfram Rule 30',
    shaderAsset: 'shaders/wolfram_rule30_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'langton_ant',
    name: "Langton's Ant",
    shaderAsset: 'shaders/langton_ant_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sandpile',
    name: 'Abelian Sandpile',
    shaderAsset: 'shaders/sandpile_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'dla',
    name: 'DLA (Approximation)',
    shaderAsset: 'shaders/dla_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'forest_fire',
    name: 'Forest Fire Model',
    shaderAsset: 'shaders/forest_fire_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'percolation',
    name: 'Percolation Cluster',
    shaderAsset: 'shaders/percolation_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 4.0,
  ),
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}

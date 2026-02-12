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
  EscapeTimeConfig(
    id: 'fish',
    name: 'Fish Fractal',
    shaderAsset: 'shaders/fish_gpu.frag',
    defaultIterations: 170,
  ),
  EscapeTimeConfig(
    id: 'barnsley_j1',
    name: 'Barnsley J1',
    shaderAsset: 'shaders/barnsley_j1_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'ducky',
    name: 'Ducky Fractal',
    shaderAsset: 'shaders/ducky_gpu.frag',
    defaultIterations: 150,
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
    id: 'schroeder',
    name: "Schröder Fractal (z³ - 1)",
    shaderAsset: 'shaders/schroeder_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'secant_fractal',
    name: 'Secant Fractal (z³ - 1)',
    shaderAsset: 'shaders/secant_fractal_gpu.frag',
    defaultIterations: 90,
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

  // ── IX. Lyapunov ────────────────────────────────────────
  EscapeTimeConfig(
    id: 'lyapunov',
    name: 'Lyapunov Fractal',
    shaderAsset: 'shaders/lyapunov_gpu.frag',
    defaultIterations: 200,
    defaultCenterX: 3.0,
    defaultCenterY: 3.0,
  ),
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}

import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

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
    shaderAsset: 'shaders/legacy/mandel_step_smooth.frag',
    defaultIterations: 120,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
    extraPresets: [
      FractalPreset(
        id: 'mandelbrot-seahorse',
        moduleId: 'mandelbrot',
        name: 'Seahorse Valley',
        params: {'iterations': 350, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-0.747, 0.1),
          zoom: 25.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-elephant',
        moduleId: 'mandelbrot',
        name: 'Elephant Valley',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(0.275, 0.0),
          zoom: 15.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-spiral',
        moduleId: 'mandelbrot',
        name: 'Deep Spiral',
        params: {'iterations': 400, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-0.743643887037158, 0.131825904205330),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-lightning',
        moduleId: 'mandelbrot',
        name: 'Lightning Strike',
        params: {'iterations': 280, 'bailout': 3.0, 'colorScheme': 3},
        view: FractalViewState(
          pan: Vector2(-0.1011, 0.9563),
          zoom: 80.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-mini',
        moduleId: 'mandelbrot',
        name: 'Mini Mandelbrot',
        params: {'iterations': 450, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(-1.7497591451303785, 0.0),
          zoom: 200.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-aurora',
        moduleId: 'mandelbrot',
        name: 'Aurora Borealis',
        params: {'iterations': 200, 'bailout': 6.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-0.5, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-cosmic',
        moduleId: 'mandelbrot',
        name: 'Cosmic Web',
        params: {'iterations': 380, 'bailout': 4.5, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-0.16, 1.0405),
          zoom: 150.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      // Normal-map (bas-relief) presets — colorScheme 50-63 activates 3D shading.
      FractalPreset(
        id: 'mandelbrot-relief-sunrise',
        moduleId: 'mandelbrot',
        name: 'Bas-Relief: Sunrise',
        params: {'iterations': 280, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
          pan: Vector2(-0.5, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-relief-seahorse',
        moduleId: 'mandelbrot',
        name: 'Bas-Relief: Seahorse',
        params: {'iterations': 350, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
          pan: Vector2(-0.747, 0.1),
          zoom: 25.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelbrot-relief-moonlit',
        moduleId: 'mandelbrot',
        name: 'Bas-Relief: Moonlit',
        params: {'iterations': 400, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
          pan: Vector2(-0.743643887037158, 0.131825904205330),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  // Julia has extra params (seed cx, cy) — keep custom builder for now.
  // Phoenix has extra params (p, q) — keep custom builder for now.
  EscapeTimeConfig(
    id: 'burning_ship',
    name: 'Burning Ship',
    displayName: (l10n) => l10n.moduleBurningShip,
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_gpu.frag',
    defaultIterations: 200,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
    extraPresets: [
      FractalPreset(
        id: 'burning-ship-vessel',
        moduleId: 'burning_ship',
        name: 'The Vessel',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-armada',
        moduleId: 'burning_ship',
        name: 'Armada',
        params: {'iterations': 380, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-1.762, -0.028),
          zoom: 100.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-inferno',
        moduleId: 'burning_ship',
        name: 'Inferno Core',
        params: {'iterations': 400, 'bailout': 4.5, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(-1.8619, -0.0006),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-ghost',
        moduleId: 'burning_ship',
        name: 'Ghost Ship',
        params: {'iterations': 350, 'bailout': 4.0, 'colorScheme': 3},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 2.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-mast',
        moduleId: 'burning_ship',
        name: 'Mast & Rigging',
        params: {'iterations': 320, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-1.755, -0.035),
          zoom: 50.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-volcanic',
        moduleId: 'burning_ship',
        name: 'Volcanic Ash',
        params: {'iterations': 280, 'bailout': 3.5, 'colorScheme': 3},
        view: FractalViewState(
          pan: Vector2(-1.8, -0.01),
          zoom: 30.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-neon',
        moduleId: 'burning_ship',
        name: 'Neon Voyage',
        params: {'iterations': 300, 'bailout': 5.0, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.8,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-wreck',
        moduleId: 'burning_ship',
        name: 'Deep Sea Wreck',
        params: {'iterations': 420, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-1.7572, -0.0282),
          zoom: 200.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'burning-ship-relief',
        moduleId: 'burning_ship',
        name: 'Bas-Relief: Hull',
        params: {'iterations': 320, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn',
    name: 'Tricorn',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-relief-dawn',
        moduleId: 'tricorn',
        name: 'Bas-Relief: Dawn',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'tricorn-relief-dusk',
        moduleId: 'tricorn',
        name: 'Bas-Relief: Dusk',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.16, 0.9), zoom: 30.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'celtic',
    name: 'Celtic',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_gpu.frag',
    defaultIterations: 180,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
    extraPresets: [
      FractalPreset(
        id: 'celtic-relief-iron',
        moduleId: 'celtic',
        name: 'Bas-Relief: Iron',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'celtic-relief-storm',
        moduleId: 'celtic',
        name: 'Bas-Relief: Storm',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 4.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo',
    name: 'Buffalo',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_gpu.frag',
    defaultIterations: 180,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-relief-plains',
        moduleId: 'buffalo',
        name: 'Bas-Relief: Plains',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.5, -0.5), zoom: 1.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'buffalo-relief-stampede',
        moduleId: 'buffalo',
        name: 'Bas-Relief: Stampede',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.5), zoom: 8.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot3',
    name: 'Multibrot d=3',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot3_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'multibrot3-relief-trine',
        moduleId: 'multibrot3',
        name: 'Bas-Relief: Trine',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  // Nova has custom uniforms (relaxation instead of bailout) — keep custom builder.
  // See nova_module.dart.
  EscapeTimeConfig(
    id: 'nova_julia',
    name: 'Nova Julia',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'nova-julia-classic',
        moduleId: 'nova_julia',
        name: 'Nova Classic',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'nova-julia-spiral',
        moduleId: 'nova_julia',
        name: 'Nova Spiral',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 3.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fatou',
    name: 'Fatou Set',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/fatou_gpu.frag',
    defaultIterations: 180,
  ),
  EscapeTimeConfig(
    id: 'gamma_fractal',
    name: 'Gamma Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/gamma_gpu.frag',
    defaultIterations: 100,
  ),

  // ── New escape-time fractals (add shader + entry) ───────
  // Uncomment as shaders are implemented:
  //
  EscapeTimeConfig(
    id: 'perpendicular_mandelbrot',
    name: 'Perpendicular Mandelbrot',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'perp-mandel-relief',
        moduleId: 'perpendicular_mandelbrot',
        name: 'Stone Fold',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'lambda',
    name: 'Lambda Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/lambda_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'lambda-relief',
        moduleId: 'lambda',
        name: 'Lambda Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_1',
    name: 'Magnet Fractal (Type I)',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/magnet1_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet1-relief',
        moduleId: 'magnet_type_1',
        name: 'Magnet Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(1.0, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_2',
    name: 'Magnet Fractal (Type II)',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/magnet2_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet2-relief',
        moduleId: 'magnet_type_2',
        name: 'Magnet II Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(1.0, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_3',
    name: 'Magnet Fractal (Type III)',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/magnet3_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet3-relief',
        moduleId: 'magnet_type_3',
        name: 'Rational Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'power_sum',
    name: 'Power Sum Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/power_sum_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'power-sum-relief',
        moduleId: 'power_sum',
        name: 'Power Sum Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cactus',
    name: 'Cactus Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/cactus_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'cactus-relief',
        moduleId: 'cactus',
        name: 'Cactus Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'astroid',
    name: 'Astroid Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/astroid_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'deltoid',
    name: 'Deltoid Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/deltoid_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'eisenstein',
    name: 'Eisenstein Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/eisenstein_gpu.frag',
    defaultIterations: 170,
  ),
  EscapeTimeConfig(
    id: 'druid',
    name: 'Druid Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/druid_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'druid-relief',
        moduleId: 'druid',
        name: 'Druid Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'inverse_mandelbrot',
    name: 'Inverse Mandelbrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/inverse_mandelbrot_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'inverse-mandelbrot-relief',
        moduleId: 'inverse_mandelbrot',
        name: 'Inverse Mandelbrot Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'glynn',
    name: 'Glynn Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/glynn_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'glynn-relief',
        moduleId: 'glynn',
        name: 'Glynn Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'simonbrot',
    name: 'Simonbrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/simonbrot_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'simonbrot-relief',
        moduleId: 'simonbrot',
        name: 'Simonbrot Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'shark_fin',
    name: 'Shark Fin',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/shark_fin_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'shark-fin-relief',
        moduleId: 'shark_fin',
        name: 'Shark Fin Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manowar',
    name: 'Manowar Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/manowar_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'manowar-relief',
        moduleId: 'manowar',
        name: 'Manowar Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'spider',
    name: 'Spider Fractal',
    shaderAsset: 'shaders/escape_time_family/experimental_named/spider_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'spider-relief',
        moduleId: 'spider',
        name: 'Spider Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'collatz',
    name: 'Collatz Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/collatz_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'collatz-relief',
        moduleId: 'collatz',
        name: 'Collatz Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'popcorn',
    name: 'Popcorn Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/popcorn_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'talis',
    name: 'Talis Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/talis_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'talis-relief',
        moduleId: 'talis',
        name: 'Talis Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tetration',
    name: 'Tetration Fractal',
    shaderAsset: 'shaders/trigonometric_and_transcendental/tetration_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'tetration-relief',
        moduleId: 'tetration',
        name: 'Tetration Relief',
        params: {'iterations': 130, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── XI. IFS / Geometric Fractals ───────────────────────
  EscapeTimeConfig(
    id: 'sierpinski_triangle',
    name: 'Sierpinski Triangle',
    shaderAsset: 'shaders/ifs_and_geometric/sierpinski_triangle_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sierpinski_carpet',
    name: 'Sierpinski Carpet',
    shaderAsset: 'shaders/ifs_and_geometric/sierpinski_carpet_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'koch_snowflake',
    name: 'Koch Snowflake',
    shaderAsset: 'shaders/ifs_and_geometric/koch_snowflake_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'dragon_curve',
    name: 'Dragon Curve',
    shaderAsset: 'shaders/ifs_and_geometric/dragon_curve_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'barnsley_fern',
    name: 'Barnsley Fern',
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_fern_gpu.frag',
    defaultIterations: 120,
    defaultCenterY: 0.2,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'pythagorean_tree',
    name: 'Pythagorean Tree',
    shaderAsset: 'shaders/ifs_and_geometric/pythagorean_tree_gpu.frag',
    defaultIterations: 120,
    defaultCenterY: -0.15,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hilbert_curve',
    name: 'Hilbert Curve',
    shaderAsset: 'shaders/ifs_and_geometric/hilbert_curve_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'peano_curve',
    name: 'Peano Curve',
    shaderAsset: 'shaders/ifs_and_geometric/peano_curve_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'gosper_curve',
    name: 'Gosper Curve',
    shaderAsset: 'shaders/ifs_and_geometric/gosper_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'levy_c_curve',
    name: 'Lévy C Curve',
    shaderAsset: 'shaders/ifs_and_geometric/levy_c_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'levy_tapestry',
    name: 'Lévy Tapestry',
    shaderAsset: 'shaders/ifs_and_geometric/levy_tapestry_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'golden_dragon',
    name: 'Golden Dragon',
    shaderAsset: 'shaders/ifs_and_geometric/golden_dragon_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'twin_dragon',
    name: 'Twin Dragon',
    shaderAsset: 'shaders/ifs_and_geometric/twin_dragon_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'terdragon',
    name: 'Terdragon',
    shaderAsset: 'shaders/ifs_and_geometric/terdragon_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'chair_tiling',
    name: 'Chair Tiling',
    shaderAsset: 'shaders/ifs_and_geometric/chair_tiling_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'koch_anti_snowflake',
    name: 'Koch Anti-Snowflake',
    shaderAsset: 'shaders/ifs_and_geometric/koch_anti_snowflake_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'quadratic_koch_island',
    name: 'Quadratic Koch Island',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/quadratic_koch_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'cyclosorus_fern',
    name: 'Cyclosorus Fern',
    shaderAsset: 'shaders/ifs_and_geometric/cyclosorus_fern_gpu.frag',
    defaultIterations: 200,
    defaultCenterY: 0.2,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'menger_sponge_2d',
    name: 'Menger Sponge (2D Cross-Section)',
    shaderAsset: 'shaders/ifs_and_geometric/menger_sponge_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'vicsek_fractal',
    name: 'Vicsek Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/vicsek_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'penrose_tiling',
    name: 'Penrose Tiling (P3)',
    shaderAsset: 'shaders/ifs_and_geometric/penrose_tiling_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fibonacci_word',
    name: 'Fibonacci Word Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/fibonacci_word_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'rauzy_fractal',
    name: 'Rauzy Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/rauzy_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pinwheel_tiling',
    name: 'Pinwheel Tiling',
    shaderAsset: 'shaders/ifs_and_geometric/pinwheel_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'z_order_curve',
    name: 'Z-Order Curve (Morton)',
    shaderAsset: 'shaders/ifs_and_geometric/z_order_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'greek_cross_fractal',
    name: 'Greek Cross Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/greek_cross_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sierpinski_pentagon',
    name: 'Sierpinski Pentagon',
    shaderAsset: 'shaders/ifs_and_geometric/sierpinski_pentagon_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'hexaflake',
    name: 'Hexaflake',
    shaderAsset: 'shaders/ifs_and_geometric/hexaflake_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pentaflake',
    name: 'Pentaflake',
    shaderAsset: 'shaders/ifs_and_geometric/pentaflake_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cantor_dust',
    name: 'Cantor Dust',
    shaderAsset: 'shaders/ifs_and_geometric/cantor_dust_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'apollonian_gasket',
    name: 'Apollonian Gasket',
    shaderAsset: 'shaders/ifs_and_geometric/apollonian_gasket_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'ford_circles',
    name: 'Ford Circles',
    shaderAsset: 'shaders/ifs_and_geometric/ford_circles_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'steiner_chain',
    name: 'Steiner Chain',
    shaderAsset: 'shaders/ifs_and_geometric/steiner_chain_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cesaro_fractal',
    name: 'Cesàro Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/cesaro_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cantor_set',
    name: 'Cantor Set',
    shaderAsset: 'shaders/ifs_and_geometric/cantor_set_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fractal_canopy',
    name: 'Fractal Canopy',
    shaderAsset: 'shaders/ifs_and_geometric/fractal_canopy_gpu.frag',
    defaultIterations: 80,
    // Keep canopy iteration cap lower than generic escape-time modules to
    // avoid runaway branch expansion on mobile GPUs.
    maxIterations: 120,
    defaultCenterY: -0.15,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'benesi',
    name: 'Benesi Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/benesi_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'pseudo_kleinian',
    name: 'Pseudo-Kleinian',
    shaderAsset: 'shaders/ifs_and_geometric/pseudo_kleinian_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 10.0,
  ),

  // ── X. 2D Maps / Attractors ─────────────────────────────
  EscapeTimeConfig(
    id: 'henon',
    name: 'Hénon Map',
    shaderAsset: 'shaders/strange_attractors/henon_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'tinkerbell',
    name: 'Tinkerbell Map',
    shaderAsset: 'shaders/strange_attractors/tinkerbell_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'gingerbreadman',
    name: 'Gingerbreadman Map',
    shaderAsset: 'shaders/strange_attractors/gingerbreadman_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'lozi',
    name: 'Lozi Map',
    shaderAsset: 'shaders/strange_attractors/lozi_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'duffing',
    name: 'Duffing Map',
    shaderAsset: 'shaders/strange_attractors/duffing_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'ikeda',
    name: 'Ikeda Map',
    shaderAsset: 'shaders/strange_attractors/ikeda_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'clifford',
    name: 'Clifford Attractor',
    shaderAsset: 'shaders/strange_attractors/clifford_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'peter_de_jong',
    name: 'Peter de Jong Attractor',
    shaderAsset: 'shaders/strange_attractors/peter_de_jong_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'svensson',
    name: 'Svensson Attractor',
    shaderAsset: 'shaders/strange_attractors/svensson_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'gumowski_mira',
    name: 'Gumowski-Mira Map',
    shaderAsset: 'shaders/strange_attractors/gumowski_mira_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 48.0,
  ),
  EscapeTimeConfig(
    id: 'arnold_cat',
    name: "Arnold's Cat Map",
    shaderAsset: 'shaders/strange_attractors/arnold_cat_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'standard_map',
    name: 'Standard Map (Chirikov)',
    shaderAsset: 'shaders/strange_attractors/standard_map_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'zaslavsky',
    name: 'Zaslavsky Map',
    shaderAsset: 'shaders/strange_attractors/zaslavsky_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'kicked_rotator',
    name: 'Kicked Rotator',
    shaderAsset: 'shaders/strange_attractors/kicked_rotator_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'chua_circuit',
    name: "Chua's Circuit",
    shaderAsset: 'shaders/strange_attractors/chua_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'sprott_a',
    name: 'Sprott Case A',
    shaderAsset: 'shaders/strange_attractors/sprott_a_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'burke_shaw',
    name: 'Burke-Shaw Attractor',
    shaderAsset: 'shaders/strange_attractors/burke_shaw_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'arneodo',
    name: 'Arneodo Attractor',
    shaderAsset: 'shaders/strange_attractors/arneodo_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'thomas_attractor',
    name: 'Thomas Attractor',
    shaderAsset: 'shaders/strange_attractors/thomas_attractor_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'four_wing',
    name: 'Four-Wing Attractor',
    shaderAsset: 'shaders/strange_attractors/four_wing_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 8.0,
  ),
  EscapeTimeConfig(
    id: 'lorenz_2d',
    name: 'Lorenz Attractor (2D)',
    shaderAsset: 'shaders/strange_attractors/lorenz_2d_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 6.0,
  ),
  EscapeTimeConfig(
    id: 'rossler_2d',
    name: 'Rossler Attractor (2D)',
    shaderAsset: 'shaders/strange_attractors/rossler_2d_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'dadras',
    name: 'Dadras Attractor',
    shaderAsset: 'shaders/strange_attractors/dadras_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'chen',
    name: 'Chen Attractor',
    shaderAsset: 'shaders/strange_attractors/chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'lu_chen',
    name: 'Lu-Chen Attractor',
    shaderAsset: 'shaders/strange_attractors/lu_chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'halvorsen',
    name: 'Halvorsen Attractor',
    shaderAsset: 'shaders/strange_attractors/halvorsen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 8.0,
  ),
  EscapeTimeConfig(
    id: 'scroll_waves',
    name: 'Scroll Waves Attractor',
    shaderAsset: 'shaders/strange_attractors/scroll_waves_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'rikitake',
    name: 'Rikitake Dynamo',
    shaderAsset: 'shaders/strange_attractors/rikitake_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 18.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'aizawa',
    name: 'Aizawa Attractor',
    shaderAsset: 'shaders/strange_attractors/aizawa_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 18.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 12.0,
  ),
  EscapeTimeConfig(
    id: 'rabinovich_fabrikant',
    name: 'Rabinovich-Fabrikant Attractor',
    shaderAsset: 'shaders/strange_attractors/rabinovich_fabrikant_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultZoom: 10.0,
  ),
  EscapeTimeConfig(
    id: 'nose_hoover',
    name: 'Nosé-Hoover Attractor',
    shaderAsset: 'shaders/strange_attractors/nose_hoover_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'moore_spiegel',
    name: 'Moore-Spiegel Attractor',
    shaderAsset: 'shaders/strange_attractors/moore_spiegel_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'hadley',
    name: 'Hadley Circulation',
    shaderAsset: 'shaders/strange_attractors/hadley_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 20.0,
  ),
  EscapeTimeConfig(
    id: 'genesio_tesi',
    name: 'Genesio-Tesi Attractor',
    shaderAsset: 'shaders/strange_attractors/genesio_tesi_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 20.0,
  ),
  EscapeTimeConfig(
    id: 'liu_chen',
    name: 'Liu-Chen Attractor',
    shaderAsset: 'shaders/strange_attractors/liu_chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'newton_leipnik',
    name: 'Newton-Leipnik Attractor',
    shaderAsset: 'shaders/strange_attractors/newton_leipnik_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'bouali',
    name: 'Bouali Attractor',
    shaderAsset: 'shaders/strange_attractors/bouali_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),

  // Dequan Li (2008) — a=40, k=20, f=1.833, c=−11, d=0.16, e=0.65; dragon-wing attractor.
  EscapeTimeConfig(
    id: 'dequan_li',
    name: 'Dequan Li Attractor',
    shaderAsset: 'shaders/strange_attractors/dequan_li_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Coullet-Tresser-Arneodo (1979) — cubic Duffing oscillator; double-well potential.
  EscapeTimeConfig(
    id: 'coullet',
    name: 'Coullet Attractor',
    shaderAsset: 'shaders/strange_attractors/coullet_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sakarya — a=0.4, b=0.3; compact single-lobe attractor near origin.
  EscapeTimeConfig(
    id: 'sakarya',
    name: 'Sakarya Attractor',
    shaderAsset: 'shaders/strange_attractors/sakarya_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Qi-Chen (2005) — a=14, b=43, c=13; four-wing chaotic system.
  EscapeTimeConfig(
    id: 'qi_chen',
    name: 'Qi-Chen Attractor',
    shaderAsset: 'shaders/strange_attractors/qi_chen_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Yu-Wang (2012) — a=10, b=40, c=2, d=2.5; exponential coupling exp(xy).
  EscapeTimeConfig(
    id: 'yu_wang',
    name: 'Yu-Wang Attractor',
    shaderAsset: 'shaders/strange_attractors/yu_wang_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Zhou-Chen (2004) — a=35, b=3, c=28; Lorenz-family four-wing system.
  EscapeTimeConfig(
    id: 'zhou_chen',
    name: 'Zhou-Chen Attractor',
    shaderAsset: 'shaders/strange_attractors/zhou_chen_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // TSUCS — Two-Scroll Unified Chaotic System (Elabbasy 2007); double-scroll attractor.
  EscapeTimeConfig(
    id: 'tsucs',
    name: 'TSUCS Attractor',
    shaderAsset: 'shaders/strange_attractors/tsucs_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Lorenz-84 atmospheric circulation / Rayleigh-Bénard model (Lorenz 1984).
  EscapeTimeConfig(
    id: 'rayleigh_benard',
    name: 'Rayleigh-Bénard Attractor',
    shaderAsset: 'shaders/strange_attractors/rayleigh_benard_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Robinson attractor — Duffing double-well oscillator with z feedback.
  EscapeTimeConfig(
    id: 'robinson',
    name: 'Robinson Attractor',
    shaderAsset: 'shaders/strange_attractors/robinson_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Globo-Toroid — toroidal winding chaotic system; a=0.5, b=0.5, c=1.0.
  EscapeTimeConfig(
    id: 'globo_toroid',
    name: 'Globo-Toroid Attractor',
    shaderAsset: 'shaders/strange_attractors/globo_toroid_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Tamari — Lorenz-family with reversed xz coupling; a=50, b=0.833, c=20.
  EscapeTimeConfig(
    id: 'tamari',
    name: 'Tamari Attractor',
    shaderAsset: 'shaders/strange_attractors/tamari_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Wang-Sun-Cang (2010) — tilted double-scroll; a=0.2, b=0.01, c=−0.4, d=0.5.
  EscapeTimeConfig(
    id: 'wang_sun_cang',
    name: 'Wang-Sun-Cang Attractor',
    shaderAsset: 'shaders/strange_attractors/wang_sun_cang_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // ── II. Convergent/Root-Finding (escape-time variant) ───
  EscapeTimeConfig(
    id: 'newton_z3',
    name: 'Newton Fractal (z³ - 1)',
    shaderAsset: 'shaders/root_finding/newton_z3_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'halley',
    name: "Halley's Fractal",
    shaderAsset: 'shaders/root_finding/halley_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'householder',
    name: 'Householder Fractal',
    shaderAsset: 'shaders/root_finding/householder_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet_newton',
    name: 'Magnet Newton',
    shaderAsset: 'shaders/root_finding/magnet_newton_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hypercomplex_newton',
    name: 'Hypercomplex Newton (Quaternion z³ - 1)',
    shaderAsset: 'shaders/3d_and_hypercomplex/hypercomplex_newton_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
  ),

  // ── III. Hypercomplex / Higher-dimensional slices ─────
  EscapeTimeConfig(
    id: 'quaternion_julia_2d',
    name: 'Quaternion Julia (2D Slice)',
    shaderAsset: 'shaders/3d_and_hypercomplex/quaternion_julia_2d_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'quaternion_julia_2d-relief',
        moduleId: 'quaternion_julia_2d',
        name: 'Quaternion Relief',
        params: {'iterations': 160, 'bailout': 8.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tessarine_julia',
    name: 'Tessarine Julia',
    shaderAsset: 'shaders/3d_and_hypercomplex/tessarine_julia_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'tessarine_julia-relief',
        moduleId: 'tessarine_julia',
        name: 'Tessarine Relief',
        params: {'iterations': 160, 'bailout': 8.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'split_complex',
    name: 'Split-Complex Fractal',
    shaderAsset: 'shaders/3d_and_hypercomplex/split_complex_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 10.0,
    extraPresets: [
      FractalPreset(
        id: 'split_complex-relief',
        moduleId: 'split_complex',
        name: 'Split-Complex Relief',
        params: {'iterations': 180, 'bailout': 10.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'dual_complex',
    name: 'Dual-Complex Fractal',
    shaderAsset: 'shaders/3d_and_hypercomplex/dual_complex_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'bicomplex',
    name: 'Bicomplex Mandelbrot',
    shaderAsset: 'shaders/3d_and_hypercomplex/bicomplex_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 12.0,
    extraPresets: [
      FractalPreset(
        id: 'bicomplex-relief',
        moduleId: 'bicomplex',
        name: 'Bicomplex Relief',
        params: {'iterations': 180, 'bailout': 12.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── VII. Trigonometric ──────────────────────────────────
  EscapeTimeConfig(
    id: 'sine_julia',
    name: 'Sine Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/sine_julia_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'sine-julia-relief',
        moduleId: 'sine_julia',
        name: 'Sine Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosine_julia',
    name: 'Cosine Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cosine_julia_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'cosine-julia-relief',
        moduleId: 'cosine_julia',
        name: 'Cosine Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent',
    name: 'Tangent Fractal',
    shaderAsset: 'shaders/trigonometric_and_transcendental/tangent_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      FractalPreset(
        id: 'tangent-relief',
        moduleId: 'tangent',
        name: 'Tangent Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_cosh',
    name: 'Sinh Fractal',
    shaderAsset: 'shaders/trigonometric_and_transcendental/sinh_cosh_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      FractalPreset(
        id: 'sinh-cosh-relief',
        moduleId: 'sinh_cosh',
        name: 'Sinh Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'exponential',
    name: 'Exponential Fractal',
    shaderAsset: 'shaders/trigonometric_and_transcendental/exponential_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      FractalPreset(
        id: 'exponential-relief',
        moduleId: 'exponential',
        name: 'Exponential Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'zircon_zity',
    name: 'Zircon Zity',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/zircon_zity_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      FractalPreset(
        id: 'zircon-zity-relief',
        moduleId: 'zircon_zity',
        name: 'Zircon Zity Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── VIII. Advanced Rational & Polynomial ─────────────────
  EscapeTimeConfig(
    id: 'barnsley_j1',
    name: "Barnsley J1",
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_j1_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'barnsley-j1-relief',
        moduleId: 'barnsley_j1',
        name: 'Barnsley J1 Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fish',
    name: 'Fish Fractal',
    shaderAsset: 'shaders/escape_time_family/experimental_named/fish_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'fish-relief',
        moduleId: 'fish',
        name: 'Fish Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'ducky',
    name: 'Ducky Fractal',
    shaderAsset: 'shaders/escape_time_family/experimental_named/ducky_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      FractalPreset(
        id: 'ducky-relief',
        moduleId: 'ducky',
        name: 'Ducky Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'schroeder',
    name: "Schröder's Fractal",
    shaderAsset: 'shaders/root_finding/schroeder_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_fractal',
    name: 'Secant Fractal',
    shaderAsset: 'shaders/trigonometric_and_transcendental/secant_fractal_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_cosecant',
    name: 'Secant/Cosecant Map',
    shaderAsset: 'shaders/trigonometric_and_transcendental/secant_cosecant_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 12.0,
  ),

  EscapeTimeConfig(
    id: 'taylor',
    name: 'Taylor Series Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/taylor_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'rational_map',
    name: 'Rational Map Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/rational_map_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'rational_map-relief',
        moduleId: 'rational_map',
        name: 'Rational Map Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j2',
    name: 'Barnsley J2',
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_j2_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'barnsley_j2-relief',
        moduleId: 'barnsley_j2',
        name: 'Barnsley J2 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 63},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j3',
    name: 'Barnsley J3',
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_j3_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'barnsley_j3-relief',
        moduleId: 'barnsley_j3',
        name: 'Barnsley J3 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'celtic_julia',
    name: 'Celtic Julia',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'celtic-julia-relief',
        moduleId: 'celtic_julia',
        name: 'Ember Knot',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_julia',
    name: 'Buffalo Julia',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-julia-relief',
        moduleId: 'buffalo_julia',
        name: 'Herd Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perpendicular_julia',
    name: 'Perpendicular Julia',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'perp-julia-relief',
        moduleId: 'perpendicular_julia',
        name: 'Mirror Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_julia',
    name: 'Tricorn Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-julia-relief',
        moduleId: 'tricorn_julia',
        name: 'Horn Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_julia',
    name: 'Burning Ship Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'ship-julia-relief',
        moduleId: 'burning_ship_julia',
        name: 'Flame Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_neg2',
    name: 'Multibrot d=-2',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot_neg2_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'heart',
    name: 'Heart Fractal',
    shaderAsset: 'shaders/escape_time_family/julia_variants/heart_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'cosine_mandelbrot',
    name: 'Cosine Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cosine_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    // z_{n+1}=cos(z)+c is mostly bounded near c≈0. Centering at (0,0) with
    // zoom=1 often looks fully black. Start wider and slightly left to reveal
    // escape structure immediately.
    defaultCenterX: -0.4,
    defaultZoom: 0.3,
    extraPresets: [
      FractalPreset(
        id: 'cosine-mandel-relief',
        moduleId: 'cosine_mandelbrot',
        name: 'Cosine Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.4, 0.0), zoom: 0.3, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent_mandelbrot',
    name: 'Tangent Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/tangent_mandelbrot_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tangent-mandel-relief',
        moduleId: 'tangent_mandelbrot',
        name: 'Tangent Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_mandelbrot',
    name: 'Sinh Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/sinh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'sinh-mandel-relief',
        moduleId: 'sinh_mandelbrot',
        name: 'Sinh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosh_mandelbrot',
    name: 'Cosh Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cosh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'cosh-mandel-relief',
        moduleId: 'cosh_mandelbrot',
        name: 'Cosh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tanh_mandelbrot',
    name: 'Tanh Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/tanh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tanh-mandel-relief',
        moduleId: 'tanh_mandelbrot',
        name: 'Tanh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'log_spiral',
    name: 'Log Spiral Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/log_spiral_gpu.frag',
    defaultIterations: 140,
  ),

  // ── IX. Lyapunov ────────────────────────────────────────
  EscapeTimeConfig(
    id: 'lyapunov',
    name: 'Lyapunov Fractal',
    shaderAsset: 'shaders/lyapunov_and_stability/lyapunov_gpu.frag',
    defaultIterations: 200,
    defaultCenterX: 3.0,
    defaultCenterY: 3.0,
  ),
  EscapeTimeConfig(
    id: 'logistic_lyapunov',
    name: 'Logistic Lyapunov',
    shaderAsset: 'shaders/lyapunov_and_stability/logistic_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 3.0,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'circle_map_lyapunov',
    name: 'Circle Map Lyapunov',
    shaderAsset: 'shaders/lyapunov_and_stability/circle_map_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.0,
    defaultCenterY: 1.0,
  ),
  EscapeTimeConfig(
    id: 'sine_map_lyapunov',
    name: 'Sine Map Lyapunov',
    shaderAsset: 'shaders/lyapunov_and_stability/sine_map_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.85,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'tent_map',
    name: 'Tent Map',
    shaderAsset: 'shaders/lyapunov_and_stability/tent_map_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 1.0,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'hopalong',
    name: 'Hopalong Attractor',
    shaderAsset: 'shaders/strange_attractors/hopalong_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'pickover_biomorph',
    name: 'Pickover Biomorph',
    shaderAsset: 'shaders/strange_attractors/pickover_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 64.0,
  ),
  EscapeTimeConfig(
    id: 'feigenbaum',
    name: 'Feigenbaum Logistic Map',
    shaderAsset: 'shaders/lyapunov_and_stability/feigenbaum_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: 0.25,
    defaultCenterY: 0.0,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'gauss_map',
    name: 'Gauss Map',
    shaderAsset: 'shaders/lyapunov_and_stability/gauss_map_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'buddhabrot_approx',
    name: 'Buddhabrot (Approx)',
    shaderAsset: 'shaders/escape_time_family/families/buddhabrot/buddhabrot_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'anti_buddhabrot',
    name: 'Anti-Buddhabrot',
    shaderAsset: 'shaders/escape_time_family/families/buddhabrot/anti_buddhabrot_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'nebulabrot',
    name: 'Nebulabrot (Approx)',
    shaderAsset: 'shaders/escape_time_family/families/buddhabrot/nebulabrot_gpu.frag',
    defaultIterations: 280,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),

  // ── XII. Cellular Automata & Stochastic Growth ─────────
  EscapeTimeConfig(
    id: 'wolfram_rule30',
    name: 'Wolfram Rule 30',
    shaderAsset: 'shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'langton_ant',
    name: "Langton's Ant",
    shaderAsset: 'shaders/cellular_and_stochastic/langton_ant_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'turmite',
    name: 'Turmite',
    shaderAsset: 'shaders/cellular_and_stochastic/turmite_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'wireworld',
    name: 'Wireworld',
    shaderAsset: 'shaders/cellular_and_stochastic/wireworld_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sandpile',
    name: 'Abelian Sandpile',
    shaderAsset: 'shaders/cellular_and_stochastic/sandpile_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'dla',
    name: 'DLA (Approximation)',
    shaderAsset: 'shaders/cellular_and_stochastic/dla_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'forest_fire',
    name: 'Forest Fire Model',
    shaderAsset: 'shaders/cellular_and_stochastic/forest_fire_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'percolation',
    name: 'Percolation Cluster',
    shaderAsset: 'shaders/cellular_and_stochastic/percolation_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'brian_brain',
    name: "Brian's Brain",
    shaderAsset: 'shaders/cellular_and_stochastic/brian_brain_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'highlife',
    name: 'HighLife',
    shaderAsset: 'shaders/cellular_and_stochastic/highlife_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'day_night',
    name: 'Day & Night',
    shaderAsset: 'shaders/cellular_and_stochastic/day_night_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'eden_growth',
    name: 'Eden Growth Model',
    shaderAsset: 'shaders/cellular_and_stochastic/eden_growth_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),

  // All remaining fractals already registered by subagent batches above.

  EscapeTimeConfig(
    id: 'farey_diagram',
    name: 'Farey Diagram',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/farey_diagram_gpu.frag',
    defaultIterations: 140,
    defaultCenterX: 0.0,
    defaultCenterY: 0.2,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cayley_graph',
    name: 'Cayley Graph Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/cayley_graph_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sierpinski_arrowhead',
    name: 'Sierpinski Arrowhead',
    shaderAsset: 'shaders/ifs_and_geometric/sierpinski_arrowhead_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mcworter_pentigree',
    name: "McWorter's Pentigree",
    shaderAsset: 'shaders/ifs_and_geometric/mcworter_pentigree_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'ammann_beenker',
    name: 'Ammann-Beenker Tiling',
    shaderAsset: 'shaders/ifs_and_geometric/ammann_beenker_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'moore_curve',
    name: 'Moore Curve',
    shaderAsset: 'shaders/ifs_and_geometric/moore_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'lambda_w',
    name: 'Lambda W Fractal',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/lambda_w_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'lambda_w-relief',
        moduleId: 'lambda_w',
        name: 'Lambert W Relief',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'riemann_zeta',
    name: 'Riemann Zeta Fractal',
    shaderAsset: 'shaders/trigonometric_and_transcendental/zeta_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'riemann_zeta-relief',
        moduleId: 'riemann_zeta',
        name: 'Zeta Relief',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manair_fire',
    name: 'Man-Air-Fire',
    shaderAsset: 'shaders/escape_time_family/experimental_named/manair_fire_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'spider_x',
    name: 'Spider-X',
    shaderAsset: 'shaders/escape_time_family/experimental_named/spider_x_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'spider_x-relief',
        moduleId: 'spider_x',
        name: 'Spider Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'popcorn2',
    name: 'Popcorn II',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/popcorn2_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'chebyshev',
    name: 'Chebyshev Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/chebyshev_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
    extraPresets: [
      FractalPreset(
        id: 'chebyshev-relief',
        moduleId: 'chebyshev',
        name: 'Chebyshev Relief',
        params: {'iterations': 140, 'bailout': 6.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'legendre',
    name: 'Legendre Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/legendre_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'laguerre',
    name: 'Laguerre Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/laguerre_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hermite',
    name: 'Hermite Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/hermite_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'virial',
    name: 'Virial Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/virial_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'virial-relief',
        moduleId: 'virial',
        name: 'Virial Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'newton_sin',
    name: 'Newton sin(z)',
    shaderAsset: 'shaders/root_finding/newton_sin_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_general',
    name: 'Newton Fractal (z⁴ - 1)',
    shaderAsset: 'shaders/root_finding/newton_general_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot4',
    name: 'Multibrot d=4',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot4_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'multibrot4-relief-quad',
        moduleId: 'multibrot4',
        name: 'Bas-Relief: Quad',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot5',
    name: 'Multibrot d=5',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot5_gpu.frag',
    defaultIterations: 170,
    extraPresets: [
      FractalPreset(
        id: 'multibrot5-relief-quint',
        moduleId: 'multibrot5',
        name: 'Bas-Relief: Quint',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sierpinski_tetrahedron',
    name: 'Sierpinski Tetrahedron (2D Projection)',
    shaderAsset: 'shaders/ifs_and_geometric/sierpinski_tetrahedron_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'jerusalem_cube',
    name: 'Jerusalem Cube (2D Cross-Section)',
    shaderAsset: 'shaders/ifs_and_geometric/jerusalem_cube_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'menger_3d_slice',
    name: 'Menger Sponge (3D Slice)',
    shaderAsset: 'shaders/ifs_and_geometric/menger_3d_slice_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pola_sierpinski',
    name: 'Pola-Sierpinski Hybrid',
    shaderAsset: 'shaders/ifs_and_geometric/pola_sierpinski_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fibonacci_spiral',
    name: 'Fibonacci Spiral Fractal',
    shaderAsset: 'shaders/ifs_and_geometric/fibonacci_spiral_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),

  // ── Final entries to reach 200 ─────────────────────────
  EscapeTimeConfig(
    id: 'hat_monotile',
    name: 'The Hat Monotile',
    shaderAsset: 'shaders/ifs_and_geometric/hat_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'spectre_monotile',
    name: 'The Spectre Monotile',
    shaderAsset: 'shaders/ifs_and_geometric/spectre_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'sphinx_tiling',
    name: 'Sphinx Tiling',
    shaderAsset: 'shaders/ifs_and_geometric/sphinx_tiling_gpu.frag',
    defaultIterations: 120,
  ),

  // ── From MandlebrotSetSFML open-source research ──────────────────────────

  // Log-Rotation Mandelbrot: z_{n+1} = Rot(log|z|) * z^2 + c.
  // The squared orbit is rotated by log|z_n| before adding c.
  // Creates twisted, quasi-self-similar spirals unlike any standard set.
  EscapeTimeConfig(
    id: 'washed_away',
    name: 'Washed Away',
    shaderAsset: 'shaders/escape_time_family/experimental_named/washed_away_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
  ),

  // Golden-Ratio Mandelbrot: z_{n+1} = |z|^φ * exp(i·φ·arg(z)) + c
  // where φ = (1+√5)/2 ≈ 1.618 (golden ratio).
  // Irrational exponent destroys all rotational symmetry → aperiodic geometry.
  EscapeTimeConfig(
    id: 'damaged_doublebrot',
    name: 'Damaged DoubleBrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/damaged_doublebrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: -0.3,
    extraPresets: [
      FractalPreset(
        id: 'damaged-doublebrot-relief',
        moduleId: 'damaged_doublebrot',
        name: 'Damaged DoubleBrot Relief',
        params: {'iterations': 250, 'bailout': 8.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Perpendicular Celtic: z_{n+1} = Re(z^2) + i*|Im(z^2)| + c
  // Complement to Celtic — abs on the imaginary component instead of real,
  // producing different folding symmetry and distinct spiral arm geometry.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'perp_celtic',
    name: 'Perpendicular Celtic',
    shaderAsset: 'shaders/escape_time_family/families/celtic/perp_celtic_gpu.frag',
    defaultIterations: 180,
    extraPresets: [
      FractalPreset(
        id: 'perp-celtic-relief-jade',
        moduleId: 'perp_celtic',
        name: 'Bas-Relief: Jade',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Feather Fractal: z_{n+1} = z^3 / (1 + |z|^2) + c
  // The denominator damps large orbits, producing feather-like spiraling arms
  // with rich filament structure distinct from polynomial escape-time sets.
  EscapeTimeConfig(
    id: 'feather',
    name: 'Feather Fractal',
    shaderAsset: 'shaders/escape_time_family/julia_variants/feather_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'feather-relief',
        moduleId: 'feather',
        name: 'Feather Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Cubic Burning Ship: z_{n+1} = (|Re(z)| + i·|Im(z)|)^3 + c
  // Extends the Burning Ship to power 3: richer 4-fold symmetric forms.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'burning_ship_cubic',
    name: 'Cubic Burning Ship',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'burning-ship-cubic-relief',
        moduleId: 'burning_ship_cubic',
        name: 'Bas-Relief: Forge',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Celtic Cubic: z_{n+1} = |Re(z^3)| + i·Im(z^3) + c
  // Extends Celtic to power 3 — richer aperiodic structure from 3-fold symmetry
  // combined with the Celtic abs-fold. Supports normal-map shading (50-63).
  EscapeTimeConfig(
    id: 'celtic_cubic',
    name: 'Celtic Cubic',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'celtic-cubic-relief',
        moduleId: 'celtic_cubic',
        name: 'Bas-Relief: Knot',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Mandelbrot Orbit Trap (Cross Trap)
  // Colors by minimum orbit distance to real/imaginary axes instead of escape
  // iteration count. Reveals rich banded structure in the classic black interior.
  EscapeTimeConfig(
    id: 'mandelbrot_orbit_trap',
    name: 'Mandelbrot Orbit Trap',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/mandelbrot_orbit_trap_gpu.frag',
    defaultIterations: 300,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'orbit-trap-deep',
        moduleId: 'mandelbrot_orbit_trap',
        name: 'Deep Trap',
        params: {'iterations': 500, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(-0.747, 0.1), zoom: 20.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_15',
    name: 'Multibrot d=1.5',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot_15_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'multibrot15-relief',
        moduleId: 'multibrot_15',
        name: 'Half-Power Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perp_celtic_cubic',
    name: 'Perpendicular Celtic Cubic',
    shaderAsset: 'shaders/escape_time_family/families/celtic/perp_celtic_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'perp-celtic-cubic-relief',
        moduleId: 'perp_celtic_cubic',
        name: 'Fold Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_curvature_avg',
    name: 'Mandelbrot Curvature Avg',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/mandelbrot_curvature_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'curvature-bands',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Bands',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'curvature-relief',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'julia_de',
    name: 'Julia DE Glow',
    shaderAsset: 'shaders/escape_time_family/julia_variants/julia_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'julia-de-dragon',
        moduleId: 'julia_de',
        name: 'Dragon Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'julia-de-relief',
        moduleId: 'julia_de',
        name: 'Dragon Relief',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_de',
    name: 'Mandelbrot DE Glow',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/mandelbrot_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'de-wireframe',
        moduleId: 'mandelbrot_de',
        name: 'Boundary Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'de-relief-glow',
        moduleId: 'mandelbrot_de',
        name: 'Relief Glow',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_cubic',
    name: 'Tricorn Cubic',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-cubic-relief',
        moduleId: 'tricorn_cubic',
        name: 'Triple Horn',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_tia',
    name: 'Mandelbrot TIA',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/mandelbrot_tia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'tia-organic',
        moduleId: 'mandelbrot_tia',
        name: 'Organic Flow',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 3},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'tia-relief',
        moduleId: 'mandelbrot_tia',
        name: 'TIA Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic',
    name: 'Buffalo Cubic',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-cubic-relief',
        moduleId: 'buffalo_cubic',
        name: 'Prairie Thunder',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_stripe_avg',
    name: 'Mandelbrot Stripe Average',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/mandelbrot_stripe_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'stripe-freq8',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Dense Stripe',
        params: {'iterations': 300, 'bailout': 8.0, 'colorScheme': 5},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'stripe-relief',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Stripe Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp_julia',
    name: 'Perpendicular Ship Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_perp_julia_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'perp-ship-julia-relief',
        moduleId: 'burning_ship_perp_julia',
        name: 'Filament Julia Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_25',
    name: 'Multibrot d=2.5',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot_25_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'multibrot25-relief',
        moduleId: 'multibrot_25',
        name: 'Two-and-Half Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp',
    name: 'Perpendicular Burning Ship',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_perp_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'perp-ship-relief',
        moduleId: 'burning_ship_perp',
        name: 'Filament Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(-0.5, -0.5), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── MandlebrotSetSFML batch 2 — 8 more unique formulas ──────────────────

  // Prison fractal: w=(sin x, sin y);  z_{n+1} = w² + c.
  // Component-wise sin then complex-square; creates banded prison-bar-like
  // structures in Julia space. Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'prison',
    name: 'Prison',
    shaderAsset: 'shaders/escape_time_family/experimental_named/prison_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'prison-relief',
        moduleId: 'prison',
        name: 'Prison Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Crazybrot: z_{n+1} = 1/z + c  (complex inversion).
  // Maps exterior to interior, producing "ball" structures at the origin.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'crazybrot',
    name: 'Crazybrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/crazybrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'crazybrot-relief',
        moduleId: 'crazybrot',
        name: 'Crazybrot Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Eaten fractal: a=z²;  z_{n+1} = a + c/(a+0.1).
  // The 0.1 offset prevents the singularity at z²=0, creating "eaten" notches.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'eaten',
    name: 'Eaten',
    shaderAsset: 'shaders/escape_time_family/experimental_named/eaten_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 6.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'eaten-relief',
        moduleId: 'eaten',
        name: 'Eaten Relief',
        params: {'iterations': 280, 'bailout': 6.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Polar Cowlick: r=|z|; θ=arg(z); z_{n+1} = sin(3r)·exp(i(θ+r)) + c.
  // Three radial sin-folds combined with an angular rotation by r itself.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'polar_cowlick',
    name: 'Polar Cowlick',
    shaderAsset: 'shaders/escape_time_family/experimental_named/polar_cowlick_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'polar-cowlick-relief',
        moduleId: 'polar_cowlick',
        name: 'Cowlick Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Vase fractal: F(z) = z^{1−i} + c = exp((1−i)·log z) + c.
  // Complex power (1−i) simultaneously scales and rotates, creating 3D-like
  // vase shapes especially visible in Julia views.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'vase',
    name: 'Vase',
    shaderAsset: 'shaders/escape_time_family/experimental_named/vase_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 8.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'vase-relief',
        moduleId: 'vase',
        name: 'Vase Relief',
        params: {'iterations': 220, 'bailout': 8.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // LightningBrot: z_{n+1} = z² + cos(arg z) · c.
  // The constant c is modulated by cos(angle of z), fading in/out with orbit
  // direction and creating lightning-bolt-shaped Julia sets.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'lightningbrot',
    name: 'LightningBrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/lightningbrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'lightningbrot-relief',
        moduleId: 'lightningbrot',
        name: 'Lightning Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Angrybrot: z_{n+1} = (atan(x)²−atan(y)², 2·atan(x)·y) + c.
  // Real atan compresses axes nonlinearly (saturates at ±π/2), producing a
  // sharper, more "aggressive" Mandelbrot variant with spiky filaments.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'angrybrot',
    name: 'Angrybrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/angrybrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.3,
    extraPresets: [
      FractalPreset(
        id: 'angrybrot-relief',
        moduleId: 'angrybrot',
        name: 'Angry Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Singularity fractal: z_{n+1} = (x²−y²+c_x,  2·c_x·y + c_y).
  // The imaginary update uses c_x (not x_n), creating unusual coupling:
  // near c_x=0 the set collapses; near |c_x|=1 it tilts like Mandelbrot.
  // Supports normal-map shading (colorScheme 50-63).
  EscapeTimeConfig(
    id: 'singularity',
    name: 'Singularity',
    shaderAsset: 'shaders/escape_time_family/experimental_named/singularity_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'singularity-relief',
        moduleId: 'singularity',
        name: 'Singularity Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // z² + c/(z+0.01) — offset denominator creates deep spiral arms reminiscent
  // of galaxy structures; avoids true singularity at z=0.
  EscapeTimeConfig(
    id: 'space_fractal',
    name: 'Space Fractal',
    shaderAsset: 'shaders/escape_time_family/experimental_named/space_fractal_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'space-fractal-relief',
        moduleId: 'space_fractal',
        name: 'Space Fractal Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Component-wise tan(z²+c) — tan singularities slice the plane into many
  // near-copies of the base fractal, creating a "field of contused fractals".
  EscapeTimeConfig(
    id: 'contused_fields',
    name: 'Contused Fields',
    shaderAsset: 'shaders/escape_time_family/experimental_named/contused_fields_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'contused-fields-relief',
        moduleId: 'contused_fields',
        name: 'Contused Fields Relief',
        params: {'iterations': 200, 'bailout': 10.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Rot(|z|)·sinh(z)+c — hyperbolic geometry rotated by its own magnitude;
  // creates road-like tunnel structures with distinctive symmetry.
  EscapeTimeConfig(
    id: 'car_road',
    name: 'Car Road',
    shaderAsset: 'shaders/escape_time_family/experimental_named/car_road_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'car-road-relief',
        moduleId: 'car_road',
        name: 'Car Road Relief',
        params: {'iterations': 260, 'bailout': 8.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // z²+sin(z·c)+cos(z+c) — three additive terms create a set split into
  // halves with thin filaments resembling bullets shot through the fractal.
  EscapeTimeConfig(
    id: 'bullet_shot',
    name: 'Bullet Shot',
    shaderAsset: 'shaders/escape_time_family/experimental_named/bullet_shot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'bullet-shot-relief',
        moduleId: 'bullet_shot',
        name: 'Bullet Shot Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // sin(z)+c — complex sine in Mandelbrot mode; spiral arms shaped by the
  // cosh stretching of the imaginary axis, distinct from the cosine variant.
  EscapeTimeConfig(
    id: 'sine_mandelbrot',
    name: 'Sine Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/sine_mandelbrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'sine-mandelbrot-relief',
        moduleId: 'sine_mandelbrot',
        name: 'Sine Mandelbrot Relief',
        params: {'iterations': 260, 'bailout': 10.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // √π·z²+c — standard Mandelbrot scaled by √π ≈ 1.7724; the extra factor
  // stretches escape basins and produces elongated drill-bit filaments.
  EscapeTimeConfig(
    id: 'drill',
    name: 'Drill Fractal',
    shaderAsset: 'shaders/escape_time_family/experimental_named/drill_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'drill-relief',
        moduleId: 'drill',
        name: 'Drill Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // |z|²·z+c — each component scaled by squared magnitude; non-analytic map
  // with cubic radial growth; Julia sets appear to have pseudo-3D depth.
  EscapeTimeConfig(
    id: '3d_fractal',
    name: '3D Fractal',
    shaderAsset: 'shaders/3d_and_hypercomplex/3d_fractal_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: '3d-fractal-relief',
        moduleId: '3d_fractal',
        name: '3D Fractal Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // cos(z²+c) — complex cosine applied to the Mandelbrot step; cosh growth
  // creates white "undefined" regions where the orbit diverges via cosh blow-up.
  EscapeTimeConfig(
    id: 'undefined',
    name: 'Undefined Fractal',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/undefined_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'undefined-relief',
        moduleId: 'undefined',
        name: 'Undefined Relief',
        params: {'iterations': 200, 'bailout': 10.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Sprott B (1994) — dx=yz, dy=x-y, dz=1-xy. Single-scroll attractor.
  EscapeTimeConfig(
    id: 'sprott_b',
    name: 'Sprott Case B',
    shaderAsset: 'shaders/strange_attractors/sprott_b_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott C (1994) — dx=yz, dy=x-y, dz=1-x². Double-lobe attractor.
  EscapeTimeConfig(
    id: 'sprott_c',
    name: 'Sprott Case C',
    shaderAsset: 'shaders/strange_attractors/sprott_c_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott D (1994) — dx=-y, dy=x+z, dz=xz+3y². Three-wing attractor.
  EscapeTimeConfig(
    id: 'sprott_d',
    name: 'Sprott Case D',
    shaderAsset: 'shaders/strange_attractors/sprott_d_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott E (1994) — dx=yz, dy=x²-y, dz=1-4x. Figure-eight cross-section.
  EscapeTimeConfig(
    id: 'sprott_e',
    name: 'Sprott Case E',
    shaderAsset: 'shaders/strange_attractors/sprott_e_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott F (1994) — dx=y+z, dy=-x+y/2, dz=x²-z. C-shaped single-scroll.
  EscapeTimeConfig(
    id: 'sprott_f',
    name: 'Sprott Case F',
    shaderAsset: 'shaders/strange_attractors/sprott_f_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Rucklidge (1992) — κ=2, λ=6.7; magnetoconvection model with spiral lobes.
  EscapeTimeConfig(
    id: 'rucklidge',
    name: 'Rucklidge Attractor',
    shaderAsset: 'shaders/strange_attractors/rucklidge_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Shimizu-Morioka (1980) — a=0.75, b=0.45; period-doubling route to chaos.
  EscapeTimeConfig(
    id: 'shimizu_morioka',
    name: 'Shimizu-Morioka Attractor',
    shaderAsset: 'shaders/strange_attractors/shimizu_morioka_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Chen-Lee (2004) — a=5, b=-10, c=-0.38; gyroscope rigid-body dynamics.
  EscapeTimeConfig(
    id: 'chen_lee',
    name: 'Chen-Lee Attractor',
    shaderAsset: 'shaders/strange_attractors/chen_lee_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // ── Batch 14 — Newton extensions, transcendental Julia, power-law families ─

  // Newton z^4−1=0: four roots at ±1, ±i — cross-symmetric basin pattern.
  EscapeTimeConfig(
    id: 'newton_z4',
    name: 'Newton z⁴−1',
    shaderAsset: 'shaders/root_finding/newton_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

  // Newton z^6−1=0: six roots at 60° intervals — snowflake basin symmetry.
  EscapeTimeConfig(
    id: 'newton_z6',
    name: 'Newton z⁶−1',
    shaderAsset: 'shaders/root_finding/newton_z6_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

  // Julia set of f(z)=c·tan(z), c=(0.12,0.48) — canals near tangent poles.
  EscapeTimeConfig(
    id: 'tangent_julia',
    name: 'Tangent Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/tangent_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Julia set of f(z)=c·sinh(z), c=(−0.65,0.45) — hyperbolic sine spirals.
  EscapeTimeConfig(
    id: 'sinh_julia',
    name: 'Sinh Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/sinh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Julia set of f(z)=c·cosh(z), c=(0.55,0.40) — symmetric lenticular arms.
  EscapeTimeConfig(
    id: 'cosh_julia',
    name: 'Cosh Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cosh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Julia set of f(z)=c·tanh(z), c=(0.80,0.40) — quasi-circular Fatou disks.
  EscapeTimeConfig(
    id: 'tanh_julia',
    name: 'Tanh Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/tanh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Burning Ship degree 4: (|Re|+i|Im|)^4+c — four-pronged hull structure.
  EscapeTimeConfig(
    id: 'burning_ship_power4',
    name: 'Burning Ship ⁴',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Multibrot degree 6: z^6+c — five-fold star branching at Misiurewicz pts.
  EscapeTimeConfig(
    id: 'multibrot6',
    name: 'Multibrot ⁶',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Mandelbar degree 4: conj(z)^4+c — anti-holomorphic 4-fold cusp symmetry.
  EscapeTimeConfig(
    id: 'tricorn_power4',
    name: 'Tricorn ⁴ (Mandelbar)',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Buffalo degree 4: |Re(z^4)|+i|Im(z^4)|+c — post-fold abs on degree-4 orbit.
  EscapeTimeConfig(
    id: 'buffalo_power4',
    name: 'Buffalo ⁴',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Newton z^5−1=0: five roots at 5th roots of unity — pentagonal basin symmetry.
  EscapeTimeConfig(
    id: 'newton_z5',
    name: 'Newton z⁵−1',
    shaderAsset: 'shaders/root_finding/newton_z5_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

  // Biomorph (Pickover 1986): z^2+c with |Re|<B OR |Im|<B escape test.
  // Creates organic, cell-like shapes with dendritic filaments.
  EscapeTimeConfig(
    id: 'biomorph',
    name: 'Biomorph',
    shaderAsset: 'shaders/escape_time_family/julia_variants/biomorph_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 10.0,
    extraPresets: [
      FractalPreset(
        id: 'biomorph-relief',
        moduleId: 'biomorph',
        name: 'Biomorph Relief',
        params: {'iterations': 100, 'bailout': 10.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multijulia3',
    name: 'Multijulia ³',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia3_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia4',
    name: 'Multijulia ⁴',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia5',
    name: 'Multijulia ⁵',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia6',
    name: 'Multijulia ⁶',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power4',
    name: 'Celtic ⁴',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_cubic_julia',
    name: 'Burning Ship Cubic Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power5',
    name: 'Tricorn ⁵ (Mandelbar)',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'exponential_julia',
    name: 'Exponential Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/exponential_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 50.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic_julia',
    name: 'Buffalo Cubic Julia',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet1',
    name: 'Magnet Type I',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/magnet1_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_cubic',
    name: 'Mandelbar Cubic (Tricorn ³)',
    shaderAsset: 'shaders/escape_time_family/families/mandelbar/mandelbar_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_burning_ship',
    name: 'Perpendicular Burning Ship',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_burning_ship_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power5',
    name: 'Burning Ship ⁵',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power5',
    name: 'Celtic ⁵',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power5',
    name: 'Buffalo ⁵',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot7',
    name: 'Multibrot ⁷',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot8',
    name: 'Multibrot ⁸',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia7',
    name: 'Multijulia ⁷',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia8',
    name: 'Multijulia ⁸',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_z7',
    name: 'Newton z⁷−1',
    shaderAsset: 'shaders/root_finding/newton_z7_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'feather_julia',
    name: 'Feather Julia',
    shaderAsset: 'shaders/escape_time_family/julia_variants/feather_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'heart_julia',
    name: 'Heart Julia',
    shaderAsset: 'shaders/escape_time_family/julia_variants/heart_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_z8',
    name: 'Newton z⁸−1',
    shaderAsset: 'shaders/root_finding/newton_z8_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power4_julia',
    name: 'Burning Ship⁴ Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power5_julia',
    name: 'Burning Ship⁵ Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power4_julia',
    name: 'Buffalo⁴ Julia',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power4_julia',
    name: 'Celtic⁴ Julia',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power4_julia',
    name: 'Tricorn⁴ Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power5_julia',
    name: 'Tricorn⁵ Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_burning_ship_julia',
    name: 'Perpendicular BS Julia',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_burning_ship_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'lambda_julia',
    name: 'Lambda Julia',
    shaderAsset: 'shaders/escape_time_family/julia_variants/lambda_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_cubic_julia',
    name: 'Celtic Cubic Julia',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power5_julia',
    name: 'Celtic⁵ Julia',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power5_julia',
    name: 'Buffalo⁵ Julia',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_cubic_julia',
    name: 'Tricorn Cubic Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet1_julia',
    name: 'Magnet I Julia',
    shaderAsset: 'shaders/escape_time_family/julia_variants/magnet1_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'magnet2_julia',
    name: 'Magnet II Julia',
    shaderAsset: 'shaders/escape_time_family/julia_variants/magnet2_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power6',
    name: 'Mandelbar⁶',
    shaderAsset: 'shaders/escape_time_family/families/mandelbar/mandelbar_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power6_julia',
    name: 'Tricorn⁶ Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_cubic',
    name: 'Perpendicular BS Cubic',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_bs_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_cubic_julia',
    name: 'Perp. BS Cubic Julia',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_bs_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'schroeder_z3',
    name: 'Schröder z³−1',
    shaderAsset: 'shaders/root_finding/schroeder_z3_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'schroeder_z4',
    name: 'Schröder z⁴−1',
    shaderAsset: 'shaders/root_finding/schroeder_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'nova_cubic',
    name: 'Nova Cubic',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'nova_cubic_julia',
    name: 'Nova Cubic Julia',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power6',
    name: 'Burning Ship⁶',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power6',
    name: 'Buffalo⁶',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power6',
    name: 'Celtic⁶',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot9',
    name: 'Multibrot⁹',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia9',
    name: 'Multijulia⁹',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot10',
    name: 'Multibrot¹⁰',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia10',
    name: 'Multijulia¹⁰',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot11',
    name: 'Multibrot¹¹',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot11_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot12',
    name: 'Multibrot¹²',
    shaderAsset: 'shaders/escape_time_family/families/multibrot/multibrot12_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power6_julia',
    name: 'Burning Ship⁶ Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power6_julia',
    name: 'Buffalo⁶ Julia',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power6_julia',
    name: 'Celtic⁶ Julia',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'halley_z4',
    name: 'Halley z⁴−1',
    shaderAsset: 'shaders/root_finding/halley_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power7',
    name: 'Mandelbar⁷',
    shaderAsset: 'shaders/escape_time_family/families/mandelbar/mandelbar_power7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'nova_degree4',
    name: 'Nova⁴',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_degree4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'nova_degree4_julia',
    name: 'Nova⁴ Julia',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_degree4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia7',
    name: 'Multijulia⁷',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia8',
    name: 'Multijulia⁸',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia11',
    name: 'Multijulia¹¹',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia11_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia12',
    name: 'Multijulia¹²',
    shaderAsset: 'shaders/escape_time_family/families/multijulia/multijulia12_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power8',
    name: 'Mandelbar⁸',
    shaderAsset: 'shaders/escape_time_family/families/mandelbar/mandelbar_power8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_power9',
    name: 'Mandelbar⁹',
    shaderAsset: 'shaders/escape_time_family/families/mandelbar/mandelbar_power9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power7_julia',
    name: 'Tricorn⁷ Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power7_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power8_julia',
    name: 'Tricorn⁸ Julia',
    shaderAsset: 'shaders/escape_time_family/families/tricorn/tricorn_power8_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_power4',
    name: 'Perpendicular BS⁴',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_bs_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_bs_power5',
    name: 'Perpendicular BS⁵',
    shaderAsset: 'shaders/escape_time_family/families/perpendicular/perpendicular_bs_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  // ── Batch 16 extras: novel dynamics ────────────────────────────────────
  EscapeTimeConfig(
    id: 'mandelpinski',
    name: 'Mandelpinski Necklaces',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/mandelpinski_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'mandelpinski-necklace',
        moduleId: 'mandelpinski',
        name: 'Necklace Ring',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.35, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mandelpinski-relief',
        moduleId: 'mandelpinski',
        name: 'Necklace Relief',
        params: {'iterations': 200, 'bailout': 8.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.35, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'blaschke',
    name: 'Blaschke Product',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/blaschke_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'blaschke-cantor',
        moduleId: 'blaschke',
        name: 'Cantor Circles',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'blaschke-relief',
        moduleId: 'blaschke',
        name: 'Blaschke Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fatou_exp',
    name: 'Fatou Exponential',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/fatou_exp_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 50.0,
    extraPresets: [
      FractalPreset(
        id: 'fatou-exp-spiral',
        moduleId: 'fatou_exp',
        name: 'Spiral Arms',
        params: {'iterations': 120, 'bailout': 50.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.3, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'fatou-exp-relief',
        moduleId: 'fatou_exp',
        name: 'Fatou Relief',
        params: {'iterations': 150, 'bailout': 50.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.3, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sin_z2',
    name: 'sin(z²) + c',
    shaderAsset: 'shaders/escape_time_family/transcendental_maps/sin_z2_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 20.0,
    extraPresets: [
      FractalPreset(
        id: 'sin-z2-quad',
        moduleId: 'sin_z2',
        name: 'Quad Symmetry',
        params: {'iterations': 150, 'bailout': 20.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'sin-z2-relief',
        moduleId: 'sin_z2',
        name: 'sin(z²) Relief',
        params: {'iterations': 200, 'bailout': 20.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── Batch 17: Weierstrass & Steffensen ──────────────────────────────────

  EscapeTimeConfig(
    id: 'weierstrass_p',
    name: 'Weierstrass ℘ + c',
    shaderAsset: 'shaders/trigonometric_and_transcendental/weierstrass_p_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'wp-classic',
        moduleId: 'weierstrass_p',
        name: 'Square Lattice',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'wp-relief',
        moduleId: 'weierstrass_p',
        name: '℘ Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'weierstrass_roots',
    name: 'Weierstrass Roots',
    shaderAsset: 'shaders/trigonometric_and_transcendental/weierstrass_roots_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'wroots-basins',
        moduleId: 'weierstrass_roots',
        name: 'Three Basins',
        params: {'iterations': 80, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.6, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'wroots-relief',
        moduleId: 'weierstrass_roots',
        name: 'Weierstrass Relief',
        params: {'iterations': 100, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.6, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'steffensen_z3',
    name: 'Steffensen z³−1',
    shaderAsset: 'shaders/root_finding/steffensen_z3_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'steff3-trefoil',
        moduleId: 'steffensen_z3',
        name: 'Trefoil Basins',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'steff3-golden',
        moduleId: 'steffensen_z3',
        name: 'Golden Ornaments',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 5},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'steffensen_z4',
    name: 'Steffensen z⁴−1',
    shaderAsset: 'shaders/root_finding/steffensen_z4_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'steff4-cross',
        moduleId: 'steffensen_z4',
        name: 'Cross Basins',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'steff4-sapphire',
        moduleId: 'steffensen_z4',
        name: 'Sapphire Quatrefoil',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 4},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'steffensen_z5',
    name: 'Steffensen z⁵−1',
    shaderAsset: 'shaders/root_finding/steffensen_z5_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'steff5-penta',
        moduleId: 'steffensen_z5',
        name: 'Pentagonal Basins',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'steff5-fire',
        moduleId: 'steffensen_z5',
        name: 'Fire Pentagon',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 6},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── Batch 18: Web-researched additions ──────────────────────────────────

  EscapeTimeConfig(
    id: 'damped_newton',
    name: 'Damped Newton',
    shaderAsset: 'shaders/root_finding/damped_newton_gpu.frag',
    category: 'Convergent & Root-Finding',
    defaultIterations: 120,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    extraParams: [
      FractalParameter(
        id: 'damping',
        label: (l10n) => 'Damping',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.01,
        defaultValue: 1.0,
      ),
      FractalParameter(
        id: 'polynomial',
        label: (l10n) => 'Polynomial',
        type: FractalParamType.enumeration,
        min: 0,
        max: 2,
        step: 1,
        defaultValue: 0,
        options: [
          FractalParamOption(value: 0, label: (l10n) => 'z^3 - 1'),
          FractalParamOption(value: 1, label: (l10n) => 'z^4 - 1'),
          FractalParamOption(value: 2, label: (l10n) => 'z^5 - 1'),
        ],
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'damped-newton-classic',
        moduleId: 'damped_newton',
        name: 'Cubic Basins',
        params: {
          'iterations': 120,
          'bailout': 8.0,
          'colorScheme': 2,
          'damping': 1.0,
          'polynomial': 0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.7,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'damped-newton-relaxed',
        moduleId: 'damped_newton',
        name: 'Relaxed Quartic',
        params: {
          'iterations': 140,
          'bailout': 8.0,
          'colorScheme': 1,
          'damping': 0.75,
          'polynomial': 1,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.75,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'durand_kerner',
    name: 'Durand-Kerner',
    shaderAsset: 'shaders/root_finding/durand_kerner_gpu.frag',
    category: 'Convergent & Root-Finding',
    defaultIterations: 130,
    defaultBailout: 8.0,
    defaultZoom: 0.9,
    extraParams: [
      FractalParameter(
        id: 'degree',
        label: (l10n) => 'Degree',
        type: FractalParamType.integer,
        min: 3,
        max: 7,
        step: 1,
        defaultValue: 4,
      ),
      FractalParameter(
        id: 'trackRoot',
        label: (l10n) => 'Tracked Root',
        type: FractalParamType.integer,
        min: 0,
        max: 7,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'durand-kerner-quartic',
        moduleId: 'durand_kerner',
        name: 'Quartic Rings',
        params: {
          'iterations': 130,
          'bailout': 8.0,
          'colorScheme': 0,
          'degree': 4,
          'trackRoot': 0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.9,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'durand-kerner-pentagonal',
        moduleId: 'durand_kerner',
        name: 'Pentagonal Basins',
        params: {
          'iterations': 150,
          'bailout': 8.0,
          'colorScheme': 2,
          'degree': 5,
          'trackRoot': 2,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.95,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'ehrlich_aberth',
    name: 'Ehrlich-Aberth',
    shaderAsset: 'shaders/root_finding/ehrlich_aberth_gpu.frag',
    category: 'Convergent & Root-Finding',
    defaultIterations: 120,
    defaultBailout: 8.0,
    defaultZoom: 0.85,
    extraParams: [
      FractalParameter(
        id: 'degree',
        label: (l10n) => 'Degree',
        type: FractalParamType.integer,
        min: 3,
        max: 8,
        step: 1,
        defaultValue: 4,
      ),
      FractalParameter(
        id: 'trackRoot',
        label: (l10n) => 'Tracked Root',
        type: FractalParamType.integer,
        min: 0,
        max: 7,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'ehrlich-aberth-quartic',
        moduleId: 'ehrlich_aberth',
        name: 'Quartic Attraction',
        params: {
          'iterations': 120,
          'bailout': 8.0,
          'colorScheme': 1,
          'degree': 4,
          'trackRoot': 0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.85,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'ehrlich-aberth-octic',
        moduleId: 'ehrlich_aberth',
        name: 'Octic Crown',
        params: {
          'iterations': 160,
          'bailout': 8.0,
          'colorScheme': 3,
          'degree': 8,
          'trackRoot': 3,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'mcmullen_map',
    name: 'McMullen Map',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/mcmullen_map_gpu.frag',
    category: 'Advanced Rational & Polynomial',
    defaultIterations: 180,
    defaultBailout: 6.0,
    defaultZoom: 0.9,
    extraParams: [
      FractalParameter(
        id: 'power',
        label: (l10n) => 'Power n',
        type: FractalParamType.integer,
        min: 2,
        max: 8,
        step: 1,
        defaultValue: 3,
      ),
      FractalParameter(
        id: 'aReal',
        label: (l10n) => 'a (real)',
        type: FractalParamType.float,
        min: -2.0,
        max: 2.0,
        step: 0.01,
        defaultValue: -0.1,
      ),
      FractalParameter(
        id: 'aImag',
        label: (l10n) => 'a (imag)',
        type: FractalParamType.float,
        min: -2.0,
        max: 2.0,
        step: 0.01,
        defaultValue: 0.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'mcmullen-classic',
        moduleId: 'mcmullen_map',
        name: 'Classic m=3',
        params: {
          'iterations': 180,
          'bailout': 6.0,
          'colorScheme': 0,
          'power': 3,
          'aReal': -0.1,
          'aImag': 0.0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.9,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'mcmullen-spiral',
        moduleId: 'mcmullen_map',
        name: 'Spiral Web',
        params: {
          'iterations': 220,
          'bailout': 6.0,
          'colorScheme': 2,
          'power': 5,
          'aReal': -0.2,
          'aImag': 0.18,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.05,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'generalized_mcmullen',
    name: 'Generalized McMullen',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/generalized_mcmullen_gpu.frag',
    category: 'Advanced Rational & Polynomial',
    defaultIterations: 200,
    defaultBailout: 6.0,
    defaultZoom: 0.95,
    extraParams: [
      FractalParameter(
        id: 'powerN',
        label: (l10n) => 'Power n',
        type: FractalParamType.integer,
        min: 2,
        max: 8,
        step: 1,
        defaultValue: 3,
      ),
      FractalParameter(
        id: 'powerM',
        label: (l10n) => 'Power m',
        type: FractalParamType.integer,
        min: 1,
        max: 8,
        step: 1,
        defaultValue: 3,
      ),
      FractalParameter(
        id: 'aReal',
        label: (l10n) => 'a (real)',
        type: FractalParamType.float,
        min: -2.0,
        max: 2.0,
        step: 0.01,
        defaultValue: -0.1,
      ),
      FractalParameter(
        id: 'aImag',
        label: (l10n) => 'a (imag)',
        type: FractalParamType.float,
        min: -2.0,
        max: 2.0,
        step: 0.01,
        defaultValue: 0.0,
      ),
      FractalParameter(
        id: 'bReal',
        label: (l10n) => 'b (real)',
        type: FractalParamType.float,
        min: -2.0,
        max: 2.0,
        step: 0.01,
        defaultValue: 0.0,
      ),
      FractalParameter(
        id: 'bImag',
        label: (l10n) => 'b (imag)',
        type: FractalParamType.float,
        min: -2.0,
        max: 2.0,
        step: 0.01,
        defaultValue: 0.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'generalized-mcmullen-symmetric',
        moduleId: 'generalized_mcmullen',
        name: 'Symmetric (n=3,m=3)',
        params: {
          'iterations': 200,
          'bailout': 6.0,
          'colorScheme': 1,
          'powerN': 3,
          'powerM': 3,
          'aReal': -0.1,
          'aImag': 0.0,
          'bReal': 0.0,
          'bImag': 0.0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 0.95,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'generalized-mcmullen-asymmetric',
        moduleId: 'generalized_mcmullen',
        name: 'Asymmetric (n=5,m=2)',
        params: {
          'iterations': 240,
          'bailout': 6.0,
          'colorScheme': 2,
          'powerN': 5,
          'powerM': 2,
          'aReal': -0.2,
          'aImag': 0.15,
          'bReal': 0.05,
          'bImag': -0.03,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'fractal_flame',
    name: 'Fractal Flame',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/fractal_flame_gpu.frag',
    category: 'IFS / Geometric Fractals',
    defaultIterations: 140,
    defaultBailout: 8.0,
    defaultZoom: 1.0,
    maxIterations: 200,
    extraParams: [
      FractalParameter(
        id: 'variation',
        label: (l10n) => 'Variation',
        type: FractalParamType.enumeration,
        min: 0,
        max: 4,
        step: 1,
        defaultValue: 3,
        options: [
          FractalParamOption(value: 0, label: (l10n) => 'Linear'),
          FractalParamOption(value: 1, label: (l10n) => 'Sinusoidal'),
          FractalParamOption(value: 2, label: (l10n) => 'Spherical'),
          FractalParamOption(value: 3, label: (l10n) => 'Swirl'),
          FractalParamOption(value: 4, label: (l10n) => 'Horseshoe'),
        ],
      ),
      FractalParameter(
        id: 'symmetry',
        label: (l10n) => 'Symmetry',
        type: FractalParamType.enumeration,
        min: 0,
        max: 3,
        step: 1,
        defaultValue: 2,
        options: [
          FractalParamOption(value: 0, label: (l10n) => 'None'),
          FractalParamOption(value: 1, label: (l10n) => 'Bilateral'),
          FractalParamOption(value: 2, label: (l10n) => '3-fold'),
          FractalParamOption(value: 3, label: (l10n) => '6-fold'),
        ],
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'flame-swirl-triad',
        moduleId: 'fractal_flame',
        name: 'Swirl Triad',
        params: {
          'iterations': 140,
          'bailout': 8.0,
          'colorScheme': 2,
          'variation': 3,
          'symmetry': 2,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'flame-horseshoe-kaleidoscope',
        moduleId: 'fractal_flame',
        name: 'Horseshoe Kaleidoscope',
        params: {
          'iterations': 180,
          'bailout': 8.0,
          'colorScheme': 0,
          'variation': 4,
          'symmetry': 3,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.1,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'dielectric_breakdown',
    name: 'Dielectric Breakdown',
    shaderAsset: 'shaders/cellular_and_stochastic/dielectric_breakdown_gpu.frag',
    category: 'Cellular & Stochastic Growth',
    defaultIterations: 30,
    defaultBailout: 4.0,
    defaultZoom: 1.0,
    maxIterations: 40,
    extraParams: [
      FractalParameter(
        id: 'branchDensity',
        label: (l10n) => 'Branch Density',
        type: FractalParamType.float,
        min: 0.1,
        max: 1.0,
        step: 0.01,
        defaultValue: 0.5,
      ),
      FractalParameter(
        id: 'eta',
        label: (l10n) => 'Eta',
        type: FractalParamType.float,
        min: 0.5,
        max: 3.0,
        step: 0.01,
        defaultValue: 1.0,
      ),
      FractalParameter(
        id: 'seed',
        label: (l10n) => 'Seed',
        type: FractalParamType.float,
        min: 0.0,
        max: 10.0,
        step: 0.1,
        defaultValue: 0.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'dielectric-lightning',
        moduleId: 'dielectric_breakdown',
        name: 'Lightning Tree',
        params: {
          'iterations': 30,
          'bailout': 4.0,
          'colorScheme': 1,
          'branchDensity': 0.6,
          'eta': 1.3,
          'seed': 0.0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'dielectric-filament',
        moduleId: 'dielectric_breakdown',
        name: 'Filament Storm',
        params: {
          'iterations': 40,
          'bailout': 4.0,
          'colorScheme': 2,
          'branchDensity': 0.85,
          'eta': 2.2,
          'seed': 3.0,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.15,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'lichtenberg_growth',
    name: 'Lichtenberg Growth',
    shaderAsset: 'shaders/cellular_and_stochastic/lichtenberg_growth_gpu.frag',
    category: 'Cellular & Stochastic Growth',
    defaultIterations: 30,
    defaultBailout: 4.0,
    defaultZoom: 1.0,
    maxIterations: 40,
    extraParams: [
      FractalParameter(
        id: 'growthSpeed',
        label: (l10n) => 'Growth Speed',
        type: FractalParamType.float,
        min: 0.1,
        max: 1.0,
        step: 0.01,
        defaultValue: 0.3,
      ),
      FractalParameter(
        id: 'branchAngle',
        label: (l10n) => 'Branch Angle',
        type: FractalParamType.float,
        min: 0.1,
        max: 1.5,
        step: 0.01,
        defaultValue: 0.5,
      ),
      FractalParameter(
        id: 'complexity',
        label: (l10n) => 'Complexity',
        type: FractalParamType.integer,
        min: 3,
        max: 8,
        step: 1,
        defaultValue: 5,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'lichtenberg-dendrite',
        moduleId: 'lichtenberg_growth',
        name: 'Dendrite Growth',
        params: {
          'iterations': 35,
          'bailout': 4.0,
          'colorScheme': 1,
          'growthSpeed': 0.4,
          'branchAngle': 0.6,
          'complexity': 6,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.2,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'lichtenberg-lichen',
        moduleId: 'lichtenberg_growth',
        name: 'Lichen Pattern',
        params: {
          'iterations': 25,
          'bailout': 4.0,
          'colorScheme': 3,
          'growthSpeed': 0.2,
          'branchAngle': 0.3,
          'complexity': 4,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── XVI. Kaleidoscopes ────────────────────────────────
  EscapeTimeConfig(
    id: 'kaleidoscope_basic',
    name: 'Kaleidoscope Basic',
    displayName: (l10n) => 'Kaleidoscope Basic',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_basic_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 0,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_rays',
    name: 'Kaleidoscope Rays',
    displayName: (l10n) => 'Kaleidoscope Rays',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_rays_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 1,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_mandala',
    name: 'Kaleidoscope Mandala',
    displayName: (l10n) => 'Kaleidoscope Mandala',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_mandala_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 2,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_star',
    name: 'Kaleidoscope Star',
    displayName: (l10n) => 'Kaleidoscope Star',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_star_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 0,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_snowflake',
    name: 'Kaleidoscope Snowflake',
    displayName: (l10n) => 'Kaleidoscope Snowflake',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_snowflake_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 3,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_flower',
    name: 'Kaleidoscope Flower',
    displayName: (l10n) => 'Kaleidoscope Flower',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_flower_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 1,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_jewel',
    name: 'Kaleidoscope Jewel',
    displayName: (l10n) => 'Kaleidoscope Jewel',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_jewel_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 2,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_spiral',
    name: 'Kaleidoscope Spiral',
    displayName: (l10n) => 'Kaleidoscope Spiral',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_spiral_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 0,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_geometric',
    name: 'Kaleidoscope Geometric',
    displayName: (l10n) => 'Kaleidoscope Geometric',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_geometric_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 1,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_crystal',
    name: 'Kaleidoscope Crystal',
    displayName: (l10n) => 'Kaleidoscope Crystal',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_crystal_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 2,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_wave',
    name: 'Kaleidoscope Wave',
    displayName: (l10n) => 'Kaleidoscope Wave',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_wave_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 0,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_fractal',
    name: 'Kaleidoscope Fractal',
    displayName: (l10n) => 'Kaleidoscope Fractal',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_fractal_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 1,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_rosette',
    name: 'Kaleidoscope Rosette',
    displayName: (l10n) => 'Kaleidoscope Rosette',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_rosette_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 2,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_ring',
    name: 'Kaleidoscope Ring',
    displayName: (l10n) => 'Kaleidoscope Ring',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_ring_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 0,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),
  EscapeTimeConfig(
    id: 'kaleidoscope_nebula',
    name: 'Kaleidoscope Nebula',
    displayName: (l10n) => 'Kaleidoscope Nebula',
    category: 'Kaleidoscopes',
    shaderAsset: 'shaders/kaleidoscopes/kaleidoscope_nebula_gpu.frag',
    defaultIterations: 1,
    defaultBailout: 4.0,
    defaultColorScheme: 3,
    defaultZoom: 1.0,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
  ),

  // === Merged from pre-force-update local catalog ===
  EscapeTimeConfig(
    id: 'alternated_iteration',
    name: 'Alternated Iteration',
    shaderAsset: 'shaders/escape_time_family/experimental_named/alternated_iteration_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'bedhead',
    name: 'Bedhead',
    shaderAsset: 'shaders/escape_time_family/experimental_named/bedhead_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'bogdanov_map',
    name: 'Bogdanov Map',
    shaderAsset: 'shaders/strange_attractors/bogdanov_map_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'buddhabrot_full',
    name: 'Buddhabrot Full',
    shaderAsset: 'shaders/escape_time_family/families/buddhabrot/buddhabrot_full_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'buffalo2',
    name: 'Buffalo2',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo2_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'buffalo_power7',
    name: 'Buffalo Power7',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power7_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power7',
    name: 'Burning Ship Power7',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power7_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power7_julia',
    name: 'Burning Ship Power7 Julia',
    shaderAsset: 'shaders/escape_time_family/families/burning_ship/burning_ship_power7_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'celtic2',
    name: 'Celtic2',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic2_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'celtic_power7',
    name: 'Celtic Power7',
    shaderAsset: 'shaders/escape_time_family/families/celtic/celtic_power7_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'chebyshev_fractal',
    name: 'Chebyshev Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/chebyshev_fractal_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'chebyshev_halley_param',
    name: 'Chebyshev Halley Param',
    shaderAsset: 'shaders/root_finding/chebyshev_halley_param_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'cosecant_julia',
    name: 'Cosecant Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cosecant_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'cosecant_mandelbrot',
    name: 'Cosecant Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cosecant_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'cotangent_julia',
    name: 'Cotangent Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cotangent_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'cotangent_mandelbrot',
    name: 'Cotangent Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/cotangent_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'dirichlet_eta',
    name: 'Dirichlet Eta',
    shaderAsset: 'shaders/trigonometric_and_transcendental/dirichlet_eta_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'domain_coloring',
    name: 'Domain Coloring',
    shaderAsset: 'shaders/escape_time_family/orbit_and_domain/domain_coloring_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'escape_time_perturb',
    name: 'Escape Time Perturb',
    shaderAsset: 'shaders/escape_time_family/core/escape_time_perturb_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'exp_additive_mandelbrot',
    name: 'Exp Additive Mandelbrot',
    shaderAsset: 'shaders/escape_time_family/mandelbrot_variants/exp_additive_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'fractal_dream',
    name: 'Fractal Dream',
    shaderAsset: 'shaders/escape_time_family/experimental_named/fractal_dream_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'gray_scott_rd',
    name: 'Gray Scott Rd',
    shaderAsset: 'shaders/cellular_and_stochastic/gray_scott_rd_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'hofstadter_butterfly',
    name: 'Hofstadter Butterfly',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/hofstadter_butterfly_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'inverse_quadratic',
    name: 'Inverse Quadratic',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/inverse_quadratic_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'jacobi_sn',
    name: 'Jacobi Sn',
    shaderAsset: 'shaders/trigonometric_and_transcendental/jacobi_sn_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'jarratt',
    name: 'Jarratt',
    shaderAsset: 'shaders/root_finding/jarratt_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'jason_rampe_1',
    name: 'Jason Rampe 1',
    shaderAsset: 'shaders/escape_time_family/experimental_named/jason_rampe_1_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'jason_rampe_2',
    name: 'Jason Rampe 2',
    shaderAsset: 'shaders/escape_time_family/experimental_named/jason_rampe_2_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'julia',
    name: 'Julia',
    shaderAsset: 'shaders/escape_time_family/core/julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'king',
    name: 'King',
    shaderAsset: 'shaders/escape_time_family/experimental_named/king_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'kleinian_limit_set',
    name: 'Kleinian Limit Set',
    shaderAsset: 'shaders/ifs_and_geometric/kleinian_limit_set_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'laguerre_fractal',
    name: 'Laguerre Fractal',
    shaderAsset: 'shaders/escape_time_family/newton_and_orthogonal/laguerre_fractal_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'magnetic_pendulum',
    name: 'Magnetic Pendulum',
    shaderAsset: 'shaders/escape_time_family/experimental_named/magnetic_pendulum_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_df2',
    name: 'Mandelbrot Df2',
    shaderAsset: 'shaders/legacy/mandelbrot_df2.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_et',
    name: 'Mandelbrot Et',
    shaderAsset: 'shaders/legacy/mandelbrot_et.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_hardgrad',
    name: 'Mandelbrot Hardgrad',
    shaderAsset: 'shaders/legacy/mandelbrot_hardgrad.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_simple',
    name: 'Mandelbrot Simple',
    shaderAsset: 'shaders/legacy/mandelbrot_simple.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_tex',
    name: 'Mandelbrot Tex',
    shaderAsset: 'shaders/legacy/mandelbrot_tex.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandel_julia_dual',
    name: 'Mandel Julia Dual',
    shaderAsset: 'shaders/escape_time_family/core/mandel_julia_dual_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mandel_step_escape',
    name: 'Mandel Step Escape',
    shaderAsset: 'shaders/legacy/mandel_step_escape.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'mittag_leffler',
    name: 'Mittag Leffler',
    shaderAsset: 'shaders/trigonometric_and_transcendental/mittag_leffler_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'muller',
    name: 'Muller',
    shaderAsset: 'shaders/root_finding/muller_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'neta_order16',
    name: 'Neta Order16',
    shaderAsset: 'shaders/root_finding/neta_order16_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'noor_newton',
    name: 'Noor Newton',
    shaderAsset: 'shaders/root_finding/noor_newton_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'nova_degree5',
    name: 'Nova Degree5',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_degree5_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'nova_degree5_julia',
    name: 'Nova Degree5 Julia',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_degree5_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'nova',
    name: 'Nova',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'nova_mandelbrot',
    name: 'Nova Mandelbrot',
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'orbit_trap_cross',
    name: 'Orbit Trap Cross',
    shaderAsset: 'shaders/escape_time_family/orbit_and_domain/orbit_trap_cross_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'orbit_trap_point',
    name: 'Orbit Trap Point',
    shaderAsset: 'shaders/escape_time_family/orbit_and_domain/orbit_trap_point_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'orbit_trap_ring',
    name: 'Orbit Trap Ring',
    shaderAsset: 'shaders/escape_time_family/orbit_and_domain/orbit_trap_ring_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'ostrowski',
    name: 'Ostrowski',
    shaderAsset: 'shaders/root_finding/ostrowski_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'phase_portrait',
    name: 'Phase Portrait',
    shaderAsset: 'shaders/escape_time_family/orbit_and_domain/phase_portrait_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'phoenix',
    name: 'Phoenix',
    shaderAsset: 'shaders/escape_time_family/core/phoenix_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'picard_mann_newton',
    name: 'Picard Mann Newton',
    shaderAsset: 'shaders/root_finding/picard_mann_newton_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'schroeder_z5',
    name: 'Schroeder Z5',
    shaderAsset: 'shaders/root_finding/schroeder_z5_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'schroeder_z6',
    name: 'Schroeder Z6',
    shaderAsset: 'shaders/root_finding/schroeder_z6_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'secant_julia',
    name: 'Secant Julia',
    shaderAsset: 'shaders/trigonometric_and_transcendental/secant_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'secant_mandelbrot',
    name: 'Secant Mandelbrot',
    shaderAsset: 'shaders/trigonometric_and_transcendental/secant_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'shape_modulus_julia',
    name: 'Shape Modulus Julia',
    shaderAsset: 'shaders/escape_time_family/julia_variants/shape_modulus_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sierpinski_julia_rational',
    name: 'Sierpinski Julia Rational',
    shaderAsset: 'shaders/ifs_and_geometric/sierpinski_julia_rational_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_g',
    name: 'Sprott G',
    shaderAsset: 'shaders/strange_attractors/sprott_g_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_h',
    name: 'Sprott H',
    shaderAsset: 'shaders/strange_attractors/sprott_h_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_i',
    name: 'Sprott I',
    shaderAsset: 'shaders/strange_attractors/sprott_i_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_k',
    name: 'Sprott K',
    shaderAsset: 'shaders/strange_attractors/sprott_k_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_l',
    name: 'Sprott L',
    shaderAsset: 'shaders/strange_attractors/sprott_l_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_m',
    name: 'Sprott M',
    shaderAsset: 'shaders/strange_attractors/sprott_m_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_n',
    name: 'Sprott N',
    shaderAsset: 'shaders/strange_attractors/sprott_n_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_o',
    name: 'Sprott O',
    shaderAsset: 'shaders/strange_attractors/sprott_o_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'sprott_s',
    name: 'Sprott S',
    shaderAsset: 'shaders/strange_attractors/sprott_s_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'steffensen',
    name: 'Steffensen',
    shaderAsset: 'shaders/root_finding/steffensen_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'steffensen_order8',
    name: 'Steffensen Order8',
    shaderAsset: 'shaders/root_finding/steffensen_order8_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'superexponential',
    name: 'Superexponential',
    shaderAsset: 'shaders/trigonometric_and_transcendental/superexponential_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'super_halley',
    name: 'Super Halley',
    shaderAsset: 'shaders/root_finding/super_halley_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'symmetric_icon',
    name: 'Symmetric Icon',
    shaderAsset: 'shaders/escape_time_family/geometry_and_ifs/symmetric_icon_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'transcendental_sin',
    name: 'Transcendental Sin',
    shaderAsset: 'shaders/trigonometric_and_transcendental/transcendental_sin_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'traub_ostrowski',
    name: 'Traub Ostrowski',
    shaderAsset: 'shaders/root_finding/traub_ostrowski_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'weierstrass_elliptic',
    name: 'Weierstrass Elliptic',
    shaderAsset: 'shaders/trigonometric_and_transcendental/weierstrass_elliptic_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'weierstrass_function',
    name: 'Weierstrass Function',
    shaderAsset: 'shaders/trigonometric_and_transcendental/weierstrass_function_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
  EscapeTimeConfig(
    id: 'quaternion_julia_3d',
    name: 'Quaternion Julia 3D',
    shaderAsset: 'shaders/3d_and_hypercomplex/quaternion_julia_3d_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    defaultZoom: 0.6,
    category: '3D & Hypercomplex',
    extraParams: [
      FractalParameter(
        id: 'juliaCReal',
        label: (l10n) => l10n.paramJuliaCReal,
        type: FractalParamType.float,
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: -0.8,
      ),
      FractalParameter(
        id: 'juliaCImag',
        label: (l10n) => l10n.paramJuliaCImag,
        type: FractalParamType.float,
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: 0.156,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'quaternion-julia-3d-classic',
        moduleId: 'quaternion_julia_3d',
        name: 'Classic',
        params: {
          'iterations': 150,
          'bailout': 4.0,
          'colorScheme': 0,
          'juliaCReal': -0.8,
          'juliaCImag': 0.156
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.6, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'quaternion-julia-3d-organic',
        moduleId: 'quaternion_julia_3d',
        name: 'Organic',
        params: {
          'iterations': 200,
          'bailout': 4.0,
          'colorScheme': 1,
          'juliaCReal': -0.4,
          'juliaCImag': 0.6
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.8, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'dual_quaternion_julia',
    name: 'Dual Quaternion Julia',
    shaderAsset: 'shaders/3d_and_hypercomplex/dual_quaternion_julia_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    defaultZoom: 0.6,
    category: '3D & Hypercomplex',
    extraParams: [
      FractalParameter(
        id: 'juliaCReal',
        label: (l10n) => l10n.paramJuliaCReal,
        type: FractalParamType.float,
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: -0.8,
      ),
      FractalParameter(
        id: 'juliaCImag',
        label: (l10n) => l10n.paramJuliaCImag,
        type: FractalParamType.float,
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: 0.156,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'dual-quaternion-julia-classic',
        moduleId: 'dual_quaternion_julia',
        name: 'Classic',
        params: {
          'iterations': 150,
          'bailout': 4.0,
          'colorScheme': 0,
          'juliaCReal': -0.8,
          'juliaCImag': 0.156
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.6, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'newton_z3_nova',
    name: 'Newton z³ Nova',
    shaderAsset: 'shaders/root_finding/newton_z3_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'newton-z3-nova-classic',
        moduleId: 'newton_z3_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'newton-z3-nova-relaxed',
        moduleId: 'newton_z3_nova',
        name: 'Relaxed',
        params: {
          'iterations': 100,
          'bailout': 8.0,
          'colorScheme': 1,
          'relaxation': 1.5
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.8, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'newton_z4_nova',
    name: 'Newton z⁴ Nova',
    shaderAsset: 'shaders/root_finding/newton_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'newton-z4-nova-classic',
        moduleId: 'newton_z4_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'newton_z5_nova',
    name: 'Newton z⁵ Nova',
    shaderAsset: 'shaders/root_finding/newton_z5_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'newton-z5-nova-classic',
        moduleId: 'newton_z5_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'newton_z6_nova',
    name: 'Newton z⁶ Nova',
    shaderAsset: 'shaders/root_finding/newton_z6_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'newton-z6-nova-classic',
        moduleId: 'newton_z6_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'halley_nova',
    name: 'Halley Nova',
    shaderAsset: 'shaders/root_finding/halley_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'halley-nova-classic',
        moduleId: 'halley_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'schroeder_nova',
    name: 'Schröder Nova',
    shaderAsset: 'shaders/root_finding/schroeder_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'schroeder-nova-classic',
        moduleId: 'schroeder_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'householder_nova',
    name: 'Householder Nova',
    shaderAsset: 'shaders/root_finding/householder_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
    defaultZoom: 0.7,
    category: 'Convergent & Root-Finding',
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (l10n) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.05,
        defaultValue: 1.0,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'householder-nova-classic',
        moduleId: 'householder_nova',
        name: 'Classic',
        params: {
          'iterations': 80,
          'bailout': 8.0,
          'colorScheme': 0,
          'relaxation': 1.0
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 0.7, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'buffalo_power7_julia',
    name: 'Buffalo⁷ Julia',
    shaderAsset: 'shaders/buffalo_power7_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power7_julia',
    name: 'Celtic⁷ Julia',
    shaderAsset: 'shaders/celtic_power7_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'perpendicular_bs_power4_julia',
    name: 'Perpendicular BS⁴ Julia',
    shaderAsset: 'shaders/perpendicular_bs_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'perpendicular_bs_power5_julia',
    name: 'Perpendicular BS⁵ Julia',
    shaderAsset: 'shaders/perpendicular_bs_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'perp_celtic_julia',
    name: 'Perpendicular Celtic Julia',
    shaderAsset: 'shaders/perp_celtic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'perp_celtic_cubic_julia',
    name: 'Perpendicular Celtic³ Julia',
    shaderAsset: 'shaders/perp_celtic_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'phoenix_julia',
    name: 'Phoenix Julia',
    shaderAsset: 'shaders/escape_time_family/core/phoenix_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    category: 'Escape-Time',
    extraParams: [
      FractalParameter(
        id: 'juliaCReal',
        label: (l10n) => l10n.paramJuliaCReal,
        type: FractalParamType.float,
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: -0.8,
      ),
      FractalParameter(
        id: 'juliaCImag',
        label: (l10n) => l10n.paramJuliaCImag,
        type: FractalParamType.float,
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: 0.156,
      ),
    ],
    extraPresets: [
      FractalPreset(
        id: 'phoenix-julia-classic',
        moduleId: 'phoenix_julia',
        name: 'Classic',
        params: {
          'iterations': 180,
          'bailout': 4.0,
          'colorScheme': 0,
          'juliaCReal': -0.8,
          'juliaCImag': 0.156
        },
        view: FractalViewState(
            pan: Vector2(0, 0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'multijulia_15',
    name: 'Multijulia¹⁵',
    shaderAsset: 'shaders/multijulia_15_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'multijulia_25',
    name: 'Multijulia²⁵',
    shaderAsset: 'shaders/multijulia_25_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'burning_ship_power8_julia',
    name: 'Burning Ship⁸ Julia',
    shaderAsset: 'shaders/burning_ship_power8_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'burning_ship_power9_julia',
    name: 'Burning Ship⁹ Julia',
    shaderAsset: 'shaders/burning_ship_power9_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'burning_ship_power10_julia',
    name: 'Burning Ship¹⁰ Julia',
    shaderAsset: 'shaders/burning_ship_power10_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power8',
    name: 'Celtic⁸',
    shaderAsset: 'shaders/celtic_power8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power8_julia',
    name: 'Celtic⁸ Julia',
    shaderAsset: 'shaders/celtic_power8_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power9',
    name: 'Celtic⁹',
    shaderAsset: 'shaders/celtic_power9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power9_julia',
    name: 'Celtic⁹ Julia',
    shaderAsset: 'shaders/celtic_power9_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power10',
    name: 'Celtic¹⁰',
    shaderAsset: 'shaders/celtic_power10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'celtic_power10_julia',
    name: 'Celtic¹⁰ Julia',
    shaderAsset: 'shaders/celtic_power10_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'tricorn_power9',
    name: 'Tricorn⁹',
    shaderAsset: 'shaders/tricorn_power9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'tricorn_power9_julia',
    name: 'Tricorn⁹ Julia',
    shaderAsset: 'shaders/tricorn_power9_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'tricorn_power10',
    name: 'Tricorn¹⁰',
    shaderAsset: 'shaders/tricorn_power10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'tricorn_power10_julia',
    name: 'Tricorn¹⁰ Julia',
    shaderAsset: 'shaders/tricorn_power10_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power7',
    name: 'Buffalo⁷',
    shaderAsset: 'shaders/escape_time_family/families/buffalo/buffalo_power7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power8',
    name: 'Buffalo⁸',
    shaderAsset: 'shaders/buffalo_power8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power8_julia',
    name: 'Buffalo⁸ Julia',
    shaderAsset: 'shaders/buffalo_power8_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power9',
    name: 'Buffalo⁹',
    shaderAsset: 'shaders/buffalo_power9_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power9_julia',
    name: 'Buffalo⁹ Julia',
    shaderAsset: 'shaders/buffalo_power9_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power10',
    name: 'Buffalo¹⁰',
    shaderAsset: 'shaders/buffalo_power10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'buffalo_power10_julia',
    name: 'Buffalo¹⁰ Julia',
    shaderAsset: 'shaders/buffalo_power10_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'nova_degree6',
    name: 'Nova⁶',
    shaderAsset: 'shaders/nova_degree6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Convergent & Root-Finding',
  ),

  EscapeTimeConfig(
    id: 'nova_degree6_julia',
    name: 'Nova⁶ Julia',
    shaderAsset: 'shaders/nova_degree6_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Convergent & Root-Finding',
  ),

  EscapeTimeConfig(
    id: 'nova_degree7',
    name: 'Nova⁷',
    shaderAsset: 'shaders/nova_degree7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Convergent & Root-Finding',
  ),

  EscapeTimeConfig(
    id: 'nova_degree7_julia',
    name: 'Nova⁷ Julia',
    shaderAsset: 'shaders/nova_degree7_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Convergent & Root-Finding',
  ),

  EscapeTimeConfig(
    id: 'nova_degree8',
    name: 'Nova⁸',
    shaderAsset: 'shaders/nova_degree8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Convergent & Root-Finding',
  ),

  EscapeTimeConfig(
    id: 'nova_degree8_julia',
    name: 'Nova⁸ Julia',
    shaderAsset: 'shaders/nova_degree8_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Convergent & Root-Finding',
  ),

  EscapeTimeConfig(
    id: 'mandelbar_power10',
    name: 'Mandelbar¹⁰',
    shaderAsset: 'shaders/mandelbar_power10_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),

  EscapeTimeConfig(
    id: 'mandelbar_power10_julia',
    name: 'Mandelbar¹⁰ Julia',
    shaderAsset: 'shaders/mandelbar_power10_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    category: 'Escape-Time',
  ),
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}

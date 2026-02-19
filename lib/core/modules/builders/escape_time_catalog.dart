import 'package:flutter_fractals/core/models/fractal_preset.dart';
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
    shaderAsset: 'shaders/mandel_step_smooth.frag',
    defaultIterations: 120,
    defaultCenterX: -0.5,
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
    shaderAsset: 'shaders/burning_ship_gpu.frag',
    defaultIterations: 200,
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
    shaderAsset: 'shaders/tricorn_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-relief-dawn',
        moduleId: 'tricorn',
        name: 'Bas-Relief: Dawn',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'tricorn-relief-dusk',
        moduleId: 'tricorn',
        name: 'Bas-Relief: Dusk',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(-0.16, 0.9), zoom: 30.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'celtic',
    name: 'Celtic',
    shaderAsset: 'shaders/celtic_gpu.frag',
    defaultIterations: 180,
    extraPresets: [
      FractalPreset(
        id: 'celtic-relief-iron',
        moduleId: 'celtic',
        name: 'Bas-Relief: Iron',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'celtic-relief-storm',
        moduleId: 'celtic',
        name: 'Bas-Relief: Storm',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 4.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo',
    name: 'Buffalo',
    shaderAsset: 'shaders/buffalo_gpu.frag',
    defaultIterations: 180,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-relief-plains',
        moduleId: 'buffalo',
        name: 'Bas-Relief: Plains',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'buffalo-relief-stampede',
        moduleId: 'buffalo',
        name: 'Bas-Relief: Stampede',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(-0.3, 0.5), zoom: 8.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot3',
    name: 'Multibrot d=3',
    shaderAsset: 'shaders/multibrot3_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'multibrot3-relief-trine',
        moduleId: 'multibrot3',
        name: 'Bas-Relief: Trine',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/nova_julia_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'fatou',
    name: 'Fatou Set',
    shaderAsset: 'shaders/fatou_gpu.frag',
    defaultIterations: 180,
  ),
  EscapeTimeConfig(
    id: 'gamma_fractal',
    name: 'Gamma Fractal',
    shaderAsset: 'shaders/gamma_gpu.frag',
    defaultIterations: 100,
  ),

  // ── New escape-time fractals (add shader + entry) ───────
  // Uncomment as shaders are implemented:
  //
  EscapeTimeConfig(
    id: 'perpendicular_mandelbrot',
    name: 'Perpendicular Mandelbrot',
    shaderAsset: 'shaders/perpendicular_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'perp-mandel-relief',
        moduleId: 'perpendicular_mandelbrot',
        name: 'Stone Fold',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'lambda',
    name: 'Lambda Fractal',
    shaderAsset: 'shaders/lambda_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'lambda-relief',
        moduleId: 'lambda',
        name: 'Lambda Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_1',
    name: 'Magnet Fractal (Type I)',
    shaderAsset: 'shaders/magnet1_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet1-relief',
        moduleId: 'magnet_type_1',
        name: 'Magnet Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_2',
    name: 'Magnet Fractal (Type II)',
    shaderAsset: 'shaders/magnet2_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet2-relief',
        moduleId: 'magnet_type_2',
        name: 'Magnet II Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_3',
    name: 'Magnet Fractal (Type III)',
    shaderAsset: 'shaders/magnet3_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet3-relief',
        moduleId: 'magnet_type_3',
        name: 'Rational Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'power_sum',
    name: 'Power Sum Fractal',
    shaderAsset: 'shaders/power_sum_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'power-sum-relief',
        moduleId: 'power_sum',
        name: 'Power Sum Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cactus',
    name: 'Cactus Fractal',
    shaderAsset: 'shaders/cactus_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'cactus-relief',
        moduleId: 'cactus',
        name: 'Cactus Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
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
    extraPresets: [
      FractalPreset(
        id: 'druid-relief',
        moduleId: 'druid',
        name: 'Druid Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'inverse_mandelbrot',
    name: 'Inverse Mandelbrot',
    shaderAsset: 'shaders/inverse_mandelbrot_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'inverse-mandelbrot-relief',
        moduleId: 'inverse_mandelbrot',
        name: 'Inverse Mandelbrot Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'glynn',
    name: 'Glynn Fractal',
    shaderAsset: 'shaders/glynn_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'glynn-relief',
        moduleId: 'glynn',
        name: 'Glynn Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'simonbrot',
    name: 'Simonbrot',
    shaderAsset: 'shaders/simonbrot_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'simonbrot-relief',
        moduleId: 'simonbrot',
        name: 'Simonbrot Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'shark_fin',
    name: 'Shark Fin',
    shaderAsset: 'shaders/shark_fin_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'shark-fin-relief',
        moduleId: 'shark_fin',
        name: 'Shark Fin Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manowar',
    name: 'Manowar Fractal',
    shaderAsset: 'shaders/manowar_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'manowar-relief',
        moduleId: 'manowar',
        name: 'Manowar Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'spider',
    name: 'Spider Fractal',
    shaderAsset: 'shaders/spider_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'spider-relief',
        moduleId: 'spider',
        name: 'Spider Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'collatz',
    name: 'Collatz Fractal',
    shaderAsset: 'shaders/collatz_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'collatz-relief',
        moduleId: 'collatz',
        name: 'Collatz Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
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
    extraPresets: [
      FractalPreset(
        id: 'talis-relief',
        moduleId: 'talis',
        name: 'Talis Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tetration',
    name: 'Tetration Fractal',
    shaderAsset: 'shaders/tetration_gpu.frag',
    defaultIterations: 90,
    extraPresets: [
      FractalPreset(
        id: 'tetration-relief',
        moduleId: 'tetration',
        name: 'Tetration Relief',
        params: {'iterations': 130, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
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
    id: 'levy_tapestry',
    name: 'Lévy Tapestry',
    shaderAsset: 'shaders/levy_tapestry_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'golden_dragon',
    name: 'Golden Dragon',
    shaderAsset: 'shaders/golden_dragon_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'twin_dragon',
    name: 'Twin Dragon',
    shaderAsset: 'shaders/twin_dragon_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'terdragon',
    name: 'Terdragon',
    shaderAsset: 'shaders/terdragon_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'chair_tiling',
    name: 'Chair Tiling',
    shaderAsset: 'shaders/chair_tiling_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'koch_anti_snowflake',
    name: 'Koch Anti-Snowflake',
    shaderAsset: 'shaders/koch_anti_snowflake_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'quadratic_koch_island',
    name: 'Quadratic Koch Island',
    shaderAsset: 'shaders/quadratic_koch_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'cyclosorus_fern',
    name: 'Cyclosorus Fern',
    shaderAsset: 'shaders/cyclosorus_fern_gpu.frag',
    defaultIterations: 200,
    defaultCenterY: 0.2,
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
  EscapeTimeConfig(
    id: 'sierpinski_pentagon',
    name: 'Sierpinski Pentagon',
    shaderAsset: 'shaders/sierpinski_pentagon_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'hexaflake',
    name: 'Hexaflake',
    shaderAsset: 'shaders/hexaflake_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pentaflake',
    name: 'Pentaflake',
    shaderAsset: 'shaders/pentaflake_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cantor_dust',
    name: 'Cantor Dust',
    shaderAsset: 'shaders/cantor_dust_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'apollonian_gasket',
    name: 'Apollonian Gasket',
    shaderAsset: 'shaders/apollonian_gasket_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'ford_circles',
    name: 'Ford Circles',
    shaderAsset: 'shaders/ford_circles_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'steiner_chain',
    name: 'Steiner Chain',
    shaderAsset: 'shaders/steiner_chain_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cesaro_fractal',
    name: 'Cesàro Fractal',
    shaderAsset: 'shaders/cesaro_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cantor_set',
    name: 'Cantor Set',
    shaderAsset: 'shaders/cantor_set_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fractal_canopy',
    name: 'Fractal Canopy',
    shaderAsset: 'shaders/fractal_canopy_gpu.frag',
    defaultIterations: 80,
    defaultCenterY: -0.15,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'benesi',
    name: 'Benesi Fractal',
    shaderAsset: 'shaders/benesi_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'pseudo_kleinian',
    name: 'Pseudo-Kleinian',
    shaderAsset: 'shaders/pseudo_kleinian_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 10.0,
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
    id: 'zaslavsky',
    name: 'Zaslavsky Map',
    shaderAsset: 'shaders/zaslavsky_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'kicked_rotator',
    name: 'Kicked Rotator',
    shaderAsset: 'shaders/kicked_rotator_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 8.0,
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
  EscapeTimeConfig(
    id: 'lorenz_2d',
    name: 'Lorenz Attractor (2D)',
    shaderAsset: 'shaders/lorenz_2d_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'rossler_2d',
    name: 'Rossler Attractor (2D)',
    shaderAsset: 'shaders/rossler_2d_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'dadras',
    name: 'Dadras Attractor',
    shaderAsset: 'shaders/dadras_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'chen',
    name: 'Chen Attractor',
    shaderAsset: 'shaders/chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'lu_chen',
    name: 'Lu-Chen Attractor',
    shaderAsset: 'shaders/lu_chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'halvorsen',
    name: 'Halvorsen Attractor',
    shaderAsset: 'shaders/halvorsen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'scroll_waves',
    name: 'Scroll Waves Attractor',
    shaderAsset: 'shaders/scroll_waves_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 14.0,
  ),
  EscapeTimeConfig(
    id: 'rikitake',
    name: 'Rikitake Dynamo',
    shaderAsset: 'shaders/rikitake_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 18.0,
  ),
  EscapeTimeConfig(
    id: 'aizawa',
    name: 'Aizawa Attractor',
    shaderAsset: 'shaders/aizawa_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 18.0,
  ),
  EscapeTimeConfig(
    id: 'rabinovich_fabrikant',
    name: 'Rabinovich-Fabrikant Attractor',
    shaderAsset: 'shaders/rabinovich_fabrikant_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'nose_hoover',
    name: 'Nosé-Hoover Attractor',
    shaderAsset: 'shaders/nose_hoover_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'moore_spiegel',
    name: 'Moore-Spiegel Attractor',
    shaderAsset: 'shaders/moore_spiegel_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'hadley',
    name: 'Hadley Circulation',
    shaderAsset: 'shaders/hadley_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 20.0,
  ),
  EscapeTimeConfig(
    id: 'genesio_tesi',
    name: 'Genesio-Tesi Attractor',
    shaderAsset: 'shaders/genesio_tesi_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 20.0,
  ),
  EscapeTimeConfig(
    id: 'liu_chen',
    name: 'Liu-Chen Attractor',
    shaderAsset: 'shaders/liu_chen_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 24.0,
  ),
  EscapeTimeConfig(
    id: 'newton_leipnik',
    name: 'Newton-Leipnik Attractor',
    shaderAsset: 'shaders/newton_leipnik_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),
  EscapeTimeConfig(
    id: 'bouali',
    name: 'Bouali Attractor',
    shaderAsset: 'shaders/bouali_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 16.0,
  ),

  // Dequan Li (2008) — a=40, k=20, f=1.833, c=−11, d=0.16, e=0.65; dragon-wing attractor.
  EscapeTimeConfig(
    id: 'dequan_li',
    name: 'Dequan Li Attractor',
    shaderAsset: 'shaders/dequan_li_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Coullet-Tresser-Arneodo (1979) — cubic Duffing oscillator; double-well potential.
  EscapeTimeConfig(
    id: 'coullet',
    name: 'Coullet Attractor',
    shaderAsset: 'shaders/coullet_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sakarya — a=0.4, b=0.3; compact single-lobe attractor near origin.
  EscapeTimeConfig(
    id: 'sakarya',
    name: 'Sakarya Attractor',
    shaderAsset: 'shaders/sakarya_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Qi-Chen (2005) — a=14, b=43, c=13; four-wing chaotic system.
  EscapeTimeConfig(
    id: 'qi_chen',
    name: 'Qi-Chen Attractor',
    shaderAsset: 'shaders/qi_chen_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Yu-Wang (2012) — a=10, b=40, c=2, d=2.5; exponential coupling exp(xy).
  EscapeTimeConfig(
    id: 'yu_wang',
    name: 'Yu-Wang Attractor',
    shaderAsset: 'shaders/yu_wang_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Zhou-Chen (2004) — a=35, b=3, c=28; Lorenz-family four-wing system.
  EscapeTimeConfig(
    id: 'zhou_chen',
    name: 'Zhou-Chen Attractor',
    shaderAsset: 'shaders/zhou_chen_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // TSUCS — Two-Scroll Unified Chaotic System (Elabbasy 2007); double-scroll attractor.
  EscapeTimeConfig(
    id: 'tsucs',
    name: 'TSUCS Attractor',
    shaderAsset: 'shaders/tsucs_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Lorenz-84 atmospheric circulation / Rayleigh-Bénard model (Lorenz 1984).
  EscapeTimeConfig(
    id: 'rayleigh_benard',
    name: 'Rayleigh-Bénard Attractor',
    shaderAsset: 'shaders/rayleigh_benard_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Robinson attractor — Duffing double-well oscillator with z feedback.
  EscapeTimeConfig(
    id: 'robinson',
    name: 'Robinson Attractor',
    shaderAsset: 'shaders/robinson_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Globo-Toroid — toroidal winding chaotic system; a=0.5, b=0.5, c=1.0.
  EscapeTimeConfig(
    id: 'globo_toroid',
    name: 'Globo-Toroid Attractor',
    shaderAsset: 'shaders/globo_toroid_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Tamari — Lorenz-family with reversed xz coupling; a=50, b=0.833, c=20.
  EscapeTimeConfig(
    id: 'tamari',
    name: 'Tamari Attractor',
    shaderAsset: 'shaders/tamari_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Wang-Sun-Cang (2010) — tilted double-scroll; a=0.2, b=0.01, c=−0.4, d=0.5.
  EscapeTimeConfig(
    id: 'wang_sun_cang',
    name: 'Wang-Sun-Cang Attractor',
    shaderAsset: 'shaders/wang_sun_cang_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
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
  EscapeTimeConfig(
    id: 'householder',
    name: 'Householder Fractal',
    shaderAsset: 'shaders/householder_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet_newton',
    name: 'Magnet Newton',
    shaderAsset: 'shaders/magnet_newton_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hypercomplex_newton',
    name: 'Hypercomplex Newton (Quaternion z³ - 1)',
    shaderAsset: 'shaders/hypercomplex_newton_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
  ),

  // ── III. Hypercomplex / Higher-dimensional slices ─────
  EscapeTimeConfig(
    id: 'quaternion_julia_2d',
    name: 'Quaternion Julia (2D Slice)',
    shaderAsset: 'shaders/quaternion_julia_2d_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'quaternion_julia_2d-relief', moduleId: 'quaternion_julia_2d', name: 'Quaternion Relief',
        params: {'iterations': 160, 'bailout': 8.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tessarine_julia',
    name: 'Tessarine Julia',
    shaderAsset: 'shaders/tessarine_julia_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'tessarine_julia-relief', moduleId: 'tessarine_julia', name: 'Tessarine Relief',
        params: {'iterations': 160, 'bailout': 8.0, 'colorScheme': 62},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'split_complex',
    name: 'Split-Complex Fractal',
    shaderAsset: 'shaders/split_complex_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 10.0,
    extraPresets: [
      FractalPreset(
        id: 'split_complex-relief', moduleId: 'split_complex', name: 'Split-Complex Relief',
        params: {'iterations': 180, 'bailout': 10.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'dual_complex',
    name: 'Dual-Complex Fractal',
    shaderAsset: 'shaders/dual_complex_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'bicomplex',
    name: 'Bicomplex Mandelbrot',
    shaderAsset: 'shaders/bicomplex_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 12.0,
    extraPresets: [
      FractalPreset(
        id: 'bicomplex-relief', moduleId: 'bicomplex', name: 'Bicomplex Relief',
        params: {'iterations': 180, 'bailout': 12.0, 'colorScheme': 61},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),

  // ── VII. Trigonometric ──────────────────────────────────
  EscapeTimeConfig(
    id: 'sine_julia',
    name: 'Sine Julia',
    shaderAsset: 'shaders/sine_julia_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'sine-julia-relief',
        moduleId: 'sine_julia',
        name: 'Sine Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosine_julia',
    name: 'Cosine Julia',
    shaderAsset: 'shaders/cosine_julia_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'cosine-julia-relief',
        moduleId: 'cosine_julia',
        name: 'Cosine Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent',
    name: 'Tangent Fractal',
    shaderAsset: 'shaders/tangent_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      FractalPreset(
        id: 'tangent-relief',
        moduleId: 'tangent',
        name: 'Tangent Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_cosh',
    name: 'Sinh Fractal',
    shaderAsset: 'shaders/sinh_cosh_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      FractalPreset(
        id: 'sinh-cosh-relief',
        moduleId: 'sinh_cosh',
        name: 'Sinh Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'exponential',
    name: 'Exponential Fractal',
    shaderAsset: 'shaders/exponential_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      FractalPreset(
        id: 'exponential-relief',
        moduleId: 'exponential',
        name: 'Exponential Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'zircon_zity',
    name: 'Zircon Zity',
    shaderAsset: 'shaders/zircon_zity_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      FractalPreset(
        id: 'zircon-zity-relief',
        moduleId: 'zircon_zity',
        name: 'Zircon Zity Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── VIII. Advanced Rational & Polynomial ─────────────────
  EscapeTimeConfig(
    id: 'barnsley_j1',
    name: "Barnsley J1",
    shaderAsset: 'shaders/barnsley_j1_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'barnsley-j1-relief',
        moduleId: 'barnsley_j1',
        name: 'Barnsley J1 Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fish',
    name: 'Fish Fractal',
    shaderAsset: 'shaders/fish_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'fish-relief',
        moduleId: 'fish',
        name: 'Fish Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'ducky',
    name: 'Ducky Fractal',
    shaderAsset: 'shaders/ducky_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      FractalPreset(
        id: 'ducky-relief',
        moduleId: 'ducky',
        name: 'Ducky Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
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
  EscapeTimeConfig(
    id: 'secant_cosecant',
    name: 'Secant/Cosecant Map',
    shaderAsset: 'shaders/secant_cosecant_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 12.0,
  ),

  EscapeTimeConfig(
    id: 'taylor',
    name: 'Taylor Series Fractal',
    shaderAsset: 'shaders/taylor_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'rational_map',
    name: 'Rational Map Fractal',
    shaderAsset: 'shaders/rational_map_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'rational_map-relief', moduleId: 'rational_map', name: 'Rational Map Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j2',
    name: 'Barnsley J2',
    shaderAsset: 'shaders/barnsley_j2_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'barnsley_j2-relief', moduleId: 'barnsley_j2', name: 'Barnsley J2 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 63},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j3',
    name: 'Barnsley J3',
    shaderAsset: 'shaders/barnsley_j3_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'barnsley_j3-relief', moduleId: 'barnsley_j3', name: 'Barnsley J3 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'celtic_julia',
    name: 'Celtic Julia',
    shaderAsset: 'shaders/celtic_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'celtic-julia-relief',
        moduleId: 'celtic_julia',
        name: 'Ember Knot',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_julia',
    name: 'Buffalo Julia',
    shaderAsset: 'shaders/buffalo_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-julia-relief',
        moduleId: 'buffalo_julia',
        name: 'Herd Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perpendicular_julia',
    name: 'Perpendicular Julia',
    shaderAsset: 'shaders/perpendicular_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'perp-julia-relief',
        moduleId: 'perpendicular_julia',
        name: 'Mirror Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_julia',
    name: 'Tricorn Julia',
    shaderAsset: 'shaders/tricorn_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-julia-relief',
        moduleId: 'tricorn_julia',
        name: 'Horn Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_julia',
    name: 'Burning Ship Julia',
    shaderAsset: 'shaders/burning_ship_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'ship-julia-relief',
        moduleId: 'burning_ship_julia',
        name: 'Flame Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_neg2',
    name: 'Multibrot d=-2',
    shaderAsset: 'shaders/multibrot_neg2_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'heart',
    name: 'Heart Fractal',
    shaderAsset: 'shaders/heart_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'cosine_mandelbrot',
    name: 'Cosine Mandelbrot',
    shaderAsset: 'shaders/cosine_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'cosine-mandel-relief',
        moduleId: 'cosine_mandelbrot',
        name: 'Cosine Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent_mandelbrot',
    name: 'Tangent Mandelbrot',
    shaderAsset: 'shaders/tangent_mandelbrot_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tangent-mandel-relief',
        moduleId: 'tangent_mandelbrot',
        name: 'Tangent Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_mandelbrot',
    name: 'Sinh Mandelbrot',
    shaderAsset: 'shaders/sinh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'sinh-mandel-relief',
        moduleId: 'sinh_mandelbrot',
        name: 'Sinh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosh_mandelbrot',
    name: 'Cosh Mandelbrot',
    shaderAsset: 'shaders/cosh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'cosh-mandel-relief',
        moduleId: 'cosh_mandelbrot',
        name: 'Cosh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tanh_mandelbrot',
    name: 'Tanh Mandelbrot',
    shaderAsset: 'shaders/tanh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tanh-mandel-relief',
        moduleId: 'tanh_mandelbrot',
        name: 'Tanh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'log_spiral',
    name: 'Log Spiral Fractal',
    shaderAsset: 'shaders/log_spiral_gpu.frag',
    defaultIterations: 140,
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
  EscapeTimeConfig(
    id: 'anti_buddhabrot',
    name: 'Anti-Buddhabrot',
    shaderAsset: 'shaders/anti_buddhabrot_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'nebulabrot',
    name: 'Nebulabrot (Approx)',
    shaderAsset: 'shaders/nebulabrot_gpu.frag',
    defaultIterations: 280,
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
    id: 'turmite',
    name: 'Turmite',
    shaderAsset: 'shaders/turmite_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'wireworld',
    name: 'Wireworld',
    shaderAsset: 'shaders/wireworld_gpu.frag',
    defaultIterations: 220,
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
  EscapeTimeConfig(
    id: 'brian_brain',
    name: "Brian's Brain",
    shaderAsset: 'shaders/brian_brain_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'highlife',
    name: 'HighLife',
    shaderAsset: 'shaders/highlife_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'day_night',
    name: 'Day & Night',
    shaderAsset: 'shaders/day_night_gpu.frag',
    defaultIterations: 260,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'eden_growth',
    name: 'Eden Growth Model',
    shaderAsset: 'shaders/eden_growth_gpu.frag',
    defaultIterations: 280,
    defaultBailout: 4.0,
  ),

  // All remaining fractals already registered by subagent batches above.

  EscapeTimeConfig(
    id: 'farey_diagram',
    name: 'Farey Diagram',
    shaderAsset: 'shaders/farey_diagram_gpu.frag',
    defaultIterations: 140,
    defaultCenterX: 0.0,
    defaultCenterY: 0.2,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'cayley_graph',
    name: 'Cayley Graph Fractal',
    shaderAsset: 'shaders/cayley_graph_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'sierpinski_arrowhead',
    name: 'Sierpinski Arrowhead',
    shaderAsset: 'shaders/sierpinski_arrowhead_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'mcworter_pentigree',
    name: "McWorter's Pentigree",
    shaderAsset: 'shaders/mcworter_pentigree_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'ammann_beenker',
    name: 'Ammann-Beenker Tiling',
    shaderAsset: 'shaders/ammann_beenker_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'moore_curve',
    name: 'Moore Curve',
    shaderAsset: 'shaders/moore_curve_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'lambda_w',
    name: 'Lambda W Fractal',
    shaderAsset: 'shaders/lambda_w_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'lambda_w-relief', moduleId: 'lambda_w', name: 'Lambert W Relief',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'riemann_zeta',
    name: 'Riemann Zeta Fractal',
    shaderAsset: 'shaders/zeta_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      FractalPreset(
        id: 'riemann_zeta-relief', moduleId: 'riemann_zeta', name: 'Zeta Relief',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 51},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manair_fire',
    name: 'Man-Air-Fire',
    shaderAsset: 'shaders/manair_fire_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'spider_x',
    name: 'Spider-X',
    shaderAsset: 'shaders/spider_x_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'spider_x-relief', moduleId: 'spider_x', name: 'Spider Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'popcorn2',
    name: 'Popcorn II',
    shaderAsset: 'shaders/popcorn2_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'chebyshev',
    name: 'Chebyshev Fractal',
    shaderAsset: 'shaders/chebyshev_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
    extraPresets: [
      FractalPreset(
        id: 'chebyshev-relief', moduleId: 'chebyshev', name: 'Chebyshev Relief',
        params: {'iterations': 140, 'bailout': 6.0, 'colorScheme': 54},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'legendre',
    name: 'Legendre Fractal',
    shaderAsset: 'shaders/legendre_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'laguerre',
    name: 'Laguerre Fractal',
    shaderAsset: 'shaders/laguerre_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hermite',
    name: 'Hermite Fractal',
    shaderAsset: 'shaders/hermite_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'virial',
    name: 'Virial Fractal',
    shaderAsset: 'shaders/virial_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'virial-relief', moduleId: 'virial', name: 'Virial Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(), isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'newton_sin',
    name: 'Newton sin(z)',
    shaderAsset: 'shaders/newton_sin_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_general',
    name: 'Newton Fractal (z⁴ - 1)',
    shaderAsset: 'shaders/newton_general_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot4',
    name: 'Multibrot d=4',
    shaderAsset: 'shaders/multibrot4_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'multibrot4-relief-quad',
        moduleId: 'multibrot4',
        name: 'Bas-Relief: Quad',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot5',
    name: 'Multibrot d=5',
    shaderAsset: 'shaders/multibrot5_gpu.frag',
    defaultIterations: 170,
    extraPresets: [
      FractalPreset(
        id: 'multibrot5-relief-quint',
        moduleId: 'multibrot5',
        name: 'Bas-Relief: Quint',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sierpinski_tetrahedron',
    name: 'Sierpinski Tetrahedron (2D Projection)',
    shaderAsset: 'shaders/sierpinski_tetrahedron_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'jerusalem_cube',
    name: 'Jerusalem Cube (2D Cross-Section)',
    shaderAsset: 'shaders/jerusalem_cube_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'menger_3d_slice',
    name: 'Menger Sponge (3D Slice)',
    shaderAsset: 'shaders/menger_3d_slice_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'pola_sierpinski',
    name: 'Pola-Sierpinski Hybrid',
    shaderAsset: 'shaders/pola_sierpinski_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'fibonacci_spiral',
    name: 'Fibonacci Spiral Fractal',
    shaderAsset: 'shaders/fibonacci_spiral_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
  ),

  // ── Final entries to reach 200 ─────────────────────────
  EscapeTimeConfig(
    id: 'hat_monotile',
    name: 'The Hat Monotile',
    shaderAsset: 'shaders/hat_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'spectre_monotile',
    name: 'The Spectre Monotile',
    shaderAsset: 'shaders/spectre_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'sphinx_tiling',
    name: 'Sphinx Tiling',
    shaderAsset: 'shaders/sphinx_tiling_gpu.frag',
    defaultIterations: 120,
  ),

  // ── From MandlebrotSetSFML open-source research ──────────────────────────

  // Log-Rotation Mandelbrot: z_{n+1} = Rot(log|z|) * z^2 + c.
  // The squared orbit is rotated by log|z_n| before adding c.
  // Creates twisted, quasi-self-similar spirals unlike any standard set.
  EscapeTimeConfig(
    id: 'washed_away',
    name: 'Washed Away',
    shaderAsset: 'shaders/washed_away_gpu.frag',
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
    shaderAsset: 'shaders/damaged_doublebrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: -0.3,
    extraPresets: [
      FractalPreset(
        id: 'damaged-doublebrot-relief',
        moduleId: 'damaged_doublebrot',
        name: 'Damaged DoubleBrot Relief',
        params: {'iterations': 250, 'bailout': 8.0, 'colorScheme': 54},
        view: FractalViewState(pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/perp_celtic_gpu.frag',
    defaultIterations: 180,
    extraPresets: [
      FractalPreset(
        id: 'perp-celtic-relief-jade',
        moduleId: 'perp_celtic',
        name: 'Bas-Relief: Jade',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/feather_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'feather-relief',
        moduleId: 'feather',
        name: 'Feather Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/burning_ship_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'burning-ship-cubic-relief',
        moduleId: 'burning_ship_cubic',
        name: 'Bas-Relief: Forge',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/celtic_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'celtic-cubic-relief',
        moduleId: 'celtic_cubic',
        name: 'Bas-Relief: Knot',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/mandelbrot_orbit_trap_gpu.frag',
    defaultIterations: 300,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'orbit-trap-deep',
        moduleId: 'mandelbrot_orbit_trap',
        name: 'Deep Trap',
        params: {'iterations': 500, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(pan: Vector2(-0.747, 0.1), zoom: 20.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_15',
    name: 'Multibrot d=1.5',
    shaderAsset: 'shaders/multibrot_15_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'multibrot15-relief',
        moduleId: 'multibrot_15',
        name: 'Half-Power Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perp_celtic_cubic',
    name: 'Perpendicular Celtic Cubic',
    shaderAsset: 'shaders/perp_celtic_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'perp-celtic-cubic-relief',
        moduleId: 'perp_celtic_cubic',
        name: 'Fold Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_curvature_avg',
    name: 'Mandelbrot Curvature Avg',
    shaderAsset: 'shaders/mandelbrot_curvature_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'curvature-bands',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Bands',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 2},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'curvature-relief',
        moduleId: 'mandelbrot_curvature_avg',
        name: 'Curvature Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'julia_de',
    name: 'Julia DE Glow',
    shaderAsset: 'shaders/julia_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'julia-de-dragon',
        moduleId: 'julia_de',
        name: 'Dragon Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 0},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'julia-de-relief',
        moduleId: 'julia_de',
        name: 'Dragon Relief',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_de',
    name: 'Mandelbrot DE Glow',
    shaderAsset: 'shaders/mandelbrot_de_gpu.frag',
    defaultIterations: 250,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'de-wireframe',
        moduleId: 'mandelbrot_de',
        name: 'Boundary Glow',
        params: {'iterations': 350, 'bailout': 6.0, 'colorScheme': 1},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'de-relief-glow',
        moduleId: 'mandelbrot_de',
        name: 'Relief Glow',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_cubic',
    name: 'Tricorn Cubic',
    shaderAsset: 'shaders/tricorn_cubic_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-cubic-relief',
        moduleId: 'tricorn_cubic',
        name: 'Triple Horn',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_tia',
    name: 'Mandelbrot TIA',
    shaderAsset: 'shaders/mandelbrot_tia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'tia-organic',
        moduleId: 'mandelbrot_tia',
        name: 'Organic Flow',
        params: {'iterations': 300, 'bailout': 6.0, 'colorScheme': 3},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'tia-relief',
        moduleId: 'mandelbrot_tia',
        name: 'TIA Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic',
    name: 'Buffalo Cubic',
    shaderAsset: 'shaders/buffalo_cubic_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-cubic-relief',
        moduleId: 'buffalo_cubic',
        name: 'Prairie Thunder',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'mandelbrot_stripe_avg',
    name: 'Mandelbrot Stripe Average',
    shaderAsset: 'shaders/mandelbrot_stripe_avg_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'stripe-freq8',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Dense Stripe',
        params: {'iterations': 300, 'bailout': 8.0, 'colorScheme': 5},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
      FractalPreset(
        id: 'stripe-relief',
        moduleId: 'mandelbrot_stripe_avg',
        name: 'Stripe Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp_julia',
    name: 'Perpendicular Ship Julia',
    shaderAsset: 'shaders/burning_ship_perp_julia_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'perp-ship-julia-relief',
        moduleId: 'burning_ship_perp_julia',
        name: 'Filament Julia Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_25',
    name: 'Multibrot d=2.5',
    shaderAsset: 'shaders/multibrot_25_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'multibrot25-relief',
        moduleId: 'multibrot_25',
        name: 'Two-and-Half Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_perp',
    name: 'Perpendicular Burning Ship',
    shaderAsset: 'shaders/burning_ship_perp_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'perp-ship-relief',
        moduleId: 'burning_ship_perp',
        name: 'Filament Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(pan: Vector2(-0.5, -0.5), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/prison_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'prison-relief',
        moduleId: 'prison',
        name: 'Prison Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/crazybrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'crazybrot-relief',
        moduleId: 'crazybrot',
        name: 'Crazybrot Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/eaten_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 6.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'eaten-relief',
        moduleId: 'eaten',
        name: 'Eaten Relief',
        params: {'iterations': 280, 'bailout': 6.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/polar_cowlick_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'polar-cowlick-relief',
        moduleId: 'polar_cowlick',
        name: 'Cowlick Relief',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/vase_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 8.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'vase-relief',
        moduleId: 'vase',
        name: 'Vase Relief',
        params: {'iterations': 220, 'bailout': 8.0, 'colorScheme': 62},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/lightningbrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'lightningbrot-relief',
        moduleId: 'lightningbrot',
        name: 'Lightning Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/angrybrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.3,
    extraPresets: [
      FractalPreset(
        id: 'angrybrot-relief',
        moduleId: 'angrybrot',
        name: 'Angry Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(-0.3, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/singularity_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'singularity-relief',
        moduleId: 'singularity',
        name: 'Singularity Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/space_fractal_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'space-fractal-relief',
        moduleId: 'space_fractal',
        name: 'Space Fractal Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/contused_fields_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'contused-fields-relief',
        moduleId: 'contused_fields',
        name: 'Contused Fields Relief',
        params: {'iterations': 200, 'bailout': 10.0, 'colorScheme': 55},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/car_road_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'car-road-relief',
        moduleId: 'car_road',
        name: 'Car Road Relief',
        params: {'iterations': 260, 'bailout': 8.0, 'colorScheme': 57},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/bullet_shot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'bullet-shot-relief',
        moduleId: 'bullet_shot',
        name: 'Bullet Shot Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/sine_mandelbrot_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'sine-mandelbrot-relief',
        moduleId: 'sine_mandelbrot',
        name: 'Sine Mandelbrot Relief',
        params: {'iterations': 260, 'bailout': 10.0, 'colorScheme': 53},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/drill_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: 'drill-relief',
        moduleId: 'drill',
        name: 'Drill Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/3d_fractal_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
    defaultCenterX: -0.5,
    extraPresets: [
      FractalPreset(
        id: '3d-fractal-relief',
        moduleId: '3d_fractal',
        name: '3D Fractal Relief',
        params: {'iterations': 260, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
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
    shaderAsset: 'shaders/undefined_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 10.0,
    defaultCenterX: 0.0,
    extraPresets: [
      FractalPreset(
        id: 'undefined-relief',
        moduleId: 'undefined',
        name: 'Undefined Relief',
        params: {'iterations': 200, 'bailout': 10.0, 'colorScheme': 61},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),

  // Sprott B (1994) — dx=yz, dy=x-y, dz=1-xy. Single-scroll attractor.
  EscapeTimeConfig(
    id: 'sprott_b',
    name: 'Sprott Case B',
    shaderAsset: 'shaders/sprott_b_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott C (1994) — dx=yz, dy=x-y, dz=1-x². Double-lobe attractor.
  EscapeTimeConfig(
    id: 'sprott_c',
    name: 'Sprott Case C',
    shaderAsset: 'shaders/sprott_c_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott D (1994) — dx=-y, dy=x+z, dz=xz+3y². Three-wing attractor.
  EscapeTimeConfig(
    id: 'sprott_d',
    name: 'Sprott Case D',
    shaderAsset: 'shaders/sprott_d_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott E (1994) — dx=yz, dy=x²-y, dz=1-4x. Figure-eight cross-section.
  EscapeTimeConfig(
    id: 'sprott_e',
    name: 'Sprott Case E',
    shaderAsset: 'shaders/sprott_e_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Sprott F (1994) — dx=y+z, dy=-x+y/2, dz=x²-z. C-shaped single-scroll.
  EscapeTimeConfig(
    id: 'sprott_f',
    name: 'Sprott Case F',
    shaderAsset: 'shaders/sprott_f_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Rucklidge (1992) — κ=2, λ=6.7; magnetoconvection model with spiral lobes.
  EscapeTimeConfig(
    id: 'rucklidge',
    name: 'Rucklidge Attractor',
    shaderAsset: 'shaders/rucklidge_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Shimizu-Morioka (1980) — a=0.75, b=0.45; period-doubling route to chaos.
  EscapeTimeConfig(
    id: 'shimizu_morioka',
    name: 'Shimizu-Morioka Attractor',
    shaderAsset: 'shaders/shimizu_morioka_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // Chen-Lee (2004) — a=5, b=-10, c=-0.38; gyroscope rigid-body dynamics.
  EscapeTimeConfig(
    id: 'chen_lee',
    name: 'Chen-Lee Attractor',
    shaderAsset: 'shaders/chen_lee_gpu.frag',
    defaultIterations: 240,
    defaultBailout: 10.0,
  ),

  // ── Batch 14 — Newton extensions, transcendental Julia, power-law families ─

  // Newton z^4−1=0: four roots at ±1, ±i — cross-symmetric basin pattern.
  EscapeTimeConfig(
    id: 'newton_z4',
    name: 'Newton z⁴−1',
    shaderAsset: 'shaders/newton_z4_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

  // Newton z^6−1=0: six roots at 60° intervals — snowflake basin symmetry.
  EscapeTimeConfig(
    id: 'newton_z6',
    name: 'Newton z⁶−1',
    shaderAsset: 'shaders/newton_z6_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

  // Julia set of f(z)=c·tan(z), c=(0.12,0.48) — canals near tangent poles.
  EscapeTimeConfig(
    id: 'tangent_julia',
    name: 'Tangent Julia',
    shaderAsset: 'shaders/tangent_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Julia set of f(z)=c·sinh(z), c=(−0.65,0.45) — hyperbolic sine spirals.
  EscapeTimeConfig(
    id: 'sinh_julia',
    name: 'Sinh Julia',
    shaderAsset: 'shaders/sinh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Julia set of f(z)=c·cosh(z), c=(0.55,0.40) — symmetric lenticular arms.
  EscapeTimeConfig(
    id: 'cosh_julia',
    name: 'Cosh Julia',
    shaderAsset: 'shaders/cosh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Julia set of f(z)=c·tanh(z), c=(0.80,0.40) — quasi-circular Fatou disks.
  EscapeTimeConfig(
    id: 'tanh_julia',
    name: 'Tanh Julia',
    shaderAsset: 'shaders/tanh_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 20.0,
  ),

  // Burning Ship degree 4: (|Re|+i|Im|)^4+c — four-pronged hull structure.
  EscapeTimeConfig(
    id: 'burning_ship_power4',
    name: 'Burning Ship ⁴',
    shaderAsset: 'shaders/burning_ship_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Multibrot degree 6: z^6+c — five-fold star branching at Misiurewicz pts.
  EscapeTimeConfig(
    id: 'multibrot6',
    name: 'Multibrot ⁶',
    shaderAsset: 'shaders/multibrot6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Mandelbar degree 4: conj(z)^4+c — anti-holomorphic 4-fold cusp symmetry.
  EscapeTimeConfig(
    id: 'tricorn_power4',
    name: 'Tricorn ⁴ (Mandelbar)',
    shaderAsset: 'shaders/tricorn_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Buffalo degree 4: |Re(z^4)|+i|Im(z^4)|+c — post-fold abs on degree-4 orbit.
  EscapeTimeConfig(
    id: 'buffalo_power4',
    name: 'Buffalo ⁴',
    shaderAsset: 'shaders/buffalo_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),

  // Newton z^5−1=0: five roots at 5th roots of unity — pentagonal basin symmetry.
  EscapeTimeConfig(
    id: 'newton_z5',
    name: 'Newton z⁵−1',
    shaderAsset: 'shaders/newton_z5_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),

  // Biomorph (Pickover 1986): z^2+c with |Re|<B OR |Im|<B escape test.
  // Creates organic, cell-like shapes with dendritic filaments.
  EscapeTimeConfig(
    id: 'biomorph',
    name: 'Biomorph',
    shaderAsset: 'shaders/biomorph_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 10.0,
    extraPresets: [
      FractalPreset(
        id: 'biomorph-relief',
        moduleId: 'biomorph',
        name: 'Biomorph Relief',
        params: {'iterations': 100, 'bailout': 10.0, 'colorScheme': 52},
        view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multijulia3',
    name: 'Multijulia ³',
    shaderAsset: 'shaders/multijulia3_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia4',
    name: 'Multijulia ⁴',
    shaderAsset: 'shaders/multijulia4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia5',
    name: 'Multijulia ⁵',
    shaderAsset: 'shaders/multijulia5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia6',
    name: 'Multijulia ⁶',
    shaderAsset: 'shaders/multijulia6_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power4',
    name: 'Celtic ⁴',
    shaderAsset: 'shaders/celtic_power4_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_cubic_julia',
    name: 'Burning Ship Cubic Julia',
    shaderAsset: 'shaders/burning_ship_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power5',
    name: 'Tricorn ⁵ (Mandelbar)',
    shaderAsset: 'shaders/tricorn_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'exponential_julia',
    name: 'Exponential Julia',
    shaderAsset: 'shaders/exponential_julia_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 50.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_cubic_julia',
    name: 'Buffalo Cubic Julia',
    shaderAsset: 'shaders/buffalo_cubic_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'magnet1',
    name: 'Magnet Type I',
    shaderAsset: 'shaders/magnet1_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'mandelbar_cubic',
    name: 'Mandelbar Cubic (Tricorn ³)',
    shaderAsset: 'shaders/mandelbar_cubic_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_burning_ship',
    name: 'Perpendicular Burning Ship',
    shaderAsset: 'shaders/perpendicular_burning_ship_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power5',
    name: 'Burning Ship ⁵',
    shaderAsset: 'shaders/burning_ship_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power5',
    name: 'Celtic ⁵',
    shaderAsset: 'shaders/celtic_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power5',
    name: 'Buffalo ⁵',
    shaderAsset: 'shaders/buffalo_power5_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot7',
    name: 'Multibrot ⁷',
    shaderAsset: 'shaders/multibrot7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multibrot8',
    name: 'Multibrot ⁸',
    shaderAsset: 'shaders/multibrot8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia7',
    name: 'Multijulia ⁷',
    shaderAsset: 'shaders/multijulia7_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'multijulia8',
    name: 'Multijulia ⁸',
    shaderAsset: 'shaders/multijulia8_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_z7',
    name: 'Newton z⁷−1',
    shaderAsset: 'shaders/newton_z7_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'feather_julia',
    name: 'Feather Julia',
    shaderAsset: 'shaders/feather_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'heart_julia',
    name: 'Heart Julia',
    shaderAsset: 'shaders/heart_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'newton_z8',
    name: 'Newton z⁸−1',
    shaderAsset: 'shaders/newton_z8_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power4_julia',
    name: 'Burning Ship⁴ Julia',
    shaderAsset: 'shaders/burning_ship_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'burning_ship_power5_julia',
    name: 'Burning Ship⁵ Julia',
    shaderAsset: 'shaders/burning_ship_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'buffalo_power4_julia',
    name: 'Buffalo⁴ Julia',
    shaderAsset: 'shaders/buffalo_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'celtic_power4_julia',
    name: 'Celtic⁴ Julia',
    shaderAsset: 'shaders/celtic_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power4_julia',
    name: 'Tricorn⁴ Julia',
    shaderAsset: 'shaders/tricorn_power4_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'tricorn_power5_julia',
    name: 'Tricorn⁵ Julia',
    shaderAsset: 'shaders/tricorn_power5_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'perpendicular_burning_ship_julia',
    name: 'Perpendicular BS Julia',
    shaderAsset: 'shaders/perpendicular_burning_ship_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'lambda_julia',
    name: 'Lambda Julia',
    shaderAsset: 'shaders/lambda_julia_gpu.frag',
    defaultIterations: 200,
    defaultBailout: 4.0,
  ),
];

/// Build all currently active escape-time modules from the catalog.
List<FractalModule> buildEscapeTimeCatalogModules() {
  return escapeTimeCatalog.map(buildEscapeTimeModule).toList();
}

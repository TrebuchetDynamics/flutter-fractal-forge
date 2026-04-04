import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// Core escape-time fractal family.
///
/// Contains the foundational escape-time fractals including Mandelbrot,
/// Burning Ship, Multibrot variants, and their relatives.

final List<EscapeTimeConfig> coreEscapeTimeEntries = [
  EscapeTimeConfig(
    id: 'mandelbrot',
    name: 'Mandelbrot',
    displayName: (l10n) => l10n.moduleMandelbrot,
    shaderAsset: 'shaders/mandel_step_smooth.frag',
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
    shaderAsset: 'shaders/burning_ship_gpu.frag',
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
    shaderAsset: 'shaders/tricorn_gpu.frag',
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
    shaderAsset: 'shaders/celtic_gpu.frag',
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
    shaderAsset: 'shaders/buffalo_gpu.frag',
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
    shaderAsset: 'shaders/multibrot3_gpu.frag',
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
    shaderAsset: 'shaders/nova_julia_gpu.frag',
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
    shaderAsset: 'shaders/fatou_gpu.frag',
    defaultIterations: 180,
  ),
  EscapeTimeConfig(
    id: 'gamma_fractal',
    name: 'Gamma Fractal',
    shaderAsset: 'shaders/gamma_gpu.frag',
    defaultIterations: 100,
  ),
];

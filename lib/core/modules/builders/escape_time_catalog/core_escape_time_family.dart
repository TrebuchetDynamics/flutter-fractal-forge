part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _coreEscapeTimeFamilyCatalog = [
// ── I. Core escape-time family ──────────────────────────
  EscapeTimeConfig(
    id: 'mandelbrot',
    name: 'Mandelbrot',
    displayName: (l10n) => l10n.moduleMandelbrot,
    shaderAsset: 'shaders/legacy/escape_time/mandel_step_smooth.frag',
    defaultIterations: 120,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
    extraPresets: [
      catalogPreset(
        id: 'mandelbrot-seahorse',
        moduleId: 'mandelbrot',
        name: 'Seahorse Valley',
        params: {'iterations': 350, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-0.747, 0.1),
          zoom: 25.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-elephant',
        moduleId: 'mandelbrot',
        name: 'Elephant Valley',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(0.275, 0.0),
          zoom: 15.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-spiral',
        moduleId: 'mandelbrot',
        name: 'Deep Spiral',
        params: {'iterations': 400, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-0.743643887037158, 0.131825904205330),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-lightning',
        moduleId: 'mandelbrot',
        name: 'Lightning Strike',
        params: {'iterations': 280, 'bailout': 3.0, 'colorScheme': 3},
        view: FractalViewState(
          pan: Vector2(-0.1011, 0.9563),
          zoom: 80.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-mini',
        moduleId: 'mandelbrot',
        name: 'Mini Mandelbrot',
        params: {'iterations': 450, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(-1.7497591451303785, 0.0),
          zoom: 200.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-aurora',
        moduleId: 'mandelbrot',
        name: 'Aurora Borealis',
        params: {'iterations': 200, 'bailout': 6.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-0.5, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-cosmic',
        moduleId: 'mandelbrot',
        name: 'Cosmic Web',
        params: {'iterations': 380, 'bailout': 4.5, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-0.16, 1.0405),
          zoom: 150.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Normal-map (bas-relief) presets — colorScheme 50-63 activates 3D shading.
      catalogPreset(
        id: 'mandelbrot-relief-sunrise',
        moduleId: 'mandelbrot',
        name: 'Bas-Relief: Sunrise',
        params: {'iterations': 280, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
          pan: Vector2(-0.5, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-relief-seahorse',
        moduleId: 'mandelbrot',
        name: 'Bas-Relief: Seahorse',
        params: {'iterations': 350, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
          pan: Vector2(-0.747, 0.1),
          zoom: 25.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'mandelbrot-relief-moonlit',
        moduleId: 'mandelbrot',
        name: 'Bas-Relief: Moonlit',
        params: {'iterations': 400, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
          pan: Vector2(-0.743643887037158, 0.131825904205330),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
      ),
    ],
  ),
// Julia has extra params (seed cx, cy) — keep custom builder for now.
// Phoenix has extra params (p, q) — keep custom builder for now.
  EscapeTimeConfig(
    id: 'burning_ship',
    name: 'Burning Ship',
    displayName: (l10n) => l10n.moduleBurningShip,
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag',
    defaultIterations: 200,
    defaultCenterX: -0.5,
    defaultZoom: 0.35,
    extraParams: [
      _floatParam(
        id: 'power',
        label: 'Power',
        min: 1.0,
        max: 16.0,
        step: 0.1,
        defaultValue: 2.0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'burning-ship-vessel',
        moduleId: 'burning_ship',
        name: 'The Vessel',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-armada',
        moduleId: 'burning_ship',
        name: 'Armada',
        params: {'iterations': 380, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-1.762, -0.028),
          zoom: 100.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-inferno',
        moduleId: 'burning_ship',
        name: 'Inferno Core',
        params: {'iterations': 400, 'bailout': 4.5, 'colorScheme': 0},
        view: FractalViewState(
          pan: Vector2(-1.8619, -0.0006),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-ghost',
        moduleId: 'burning_ship',
        name: 'Ghost Ship',
        params: {'iterations': 350, 'bailout': 4.0, 'colorScheme': 3},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 2.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-mast',
        moduleId: 'burning_ship',
        name: 'Mast & Rigging',
        params: {'iterations': 320, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-1.755, -0.035),
          zoom: 50.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-volcanic',
        moduleId: 'burning_ship',
        name: 'Volcanic Ash',
        params: {'iterations': 280, 'bailout': 3.5, 'colorScheme': 3},
        view: FractalViewState(
          pan: Vector2(-1.8, -0.01),
          zoom: 30.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-neon',
        moduleId: 'burning_ship',
        name: 'Neon Voyage',
        params: {'iterations': 300, 'bailout': 5.0, 'colorScheme': 2},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.8,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-wreck',
        moduleId: 'burning_ship',
        name: 'Deep Sea Wreck',
        params: {'iterations': 420, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
          pan: Vector2(-1.7572, -0.0282),
          zoom: 200.0,
          rotation: Vector3.zero(),
        ),
      ),
      catalogPreset(
        id: 'burning-ship-relief',
        moduleId: 'burning_ship',
        name: 'Bas-Relief: Hull',
        params: {'iterations': 320, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn',
    name: 'Tricorn',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag',
    defaultIterations: 150,
    extraParams: [
      _floatParam(
        id: 'power',
        label: 'Power',
        min: 1.0,
        max: 16.0,
        step: 0.1,
        defaultValue: 2.0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'tricorn-relief-dawn',
        moduleId: 'tricorn',
        name: 'Bas-Relief: Dawn',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'tricorn-relief-dusk',
        moduleId: 'tricorn',
        name: 'Bas-Relief: Dusk',
        params: {'iterations': 250, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(-0.16, 0.9), zoom: 30.0, rotation: Vector3.zero()),
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
      catalogPreset(
        id: 'celtic-relief-iron',
        moduleId: 'celtic',
        name: 'Bas-Relief: Iron',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'celtic-relief-storm',
        moduleId: 'celtic',
        name: 'Bas-Relief: Storm',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 4.0, rotation: Vector3.zero()),
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
      catalogPreset(
        id: 'buffalo-relief-plains',
        moduleId: 'buffalo',
        name: 'Bas-Relief: Plains',
        params: {'iterations': 240, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.5, -0.5), zoom: 1.5, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'buffalo-relief-stampede',
        moduleId: 'buffalo',
        name: 'Bas-Relief: Stampede',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(-0.3, 0.5), zoom: 8.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot3',
    name: 'Multibrot d=3',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag',
    defaultIterations: 150,
    extraParams: [
      _floatParam(
        id: 'power',
        label: 'Power',
        min: -8,
        max: 24,
        step: 0.1,
        defaultValue: 3.0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'multibrot3-relief-trine',
        moduleId: 'multibrot3',
        name: 'Bas-Relief: Trine',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
// Nova has custom uniforms (relaxation instead of bailout) — keep custom builder.
// See nova_module.dart.
  EscapeTimeConfig(
    id: 'nova_julia',
    name: 'Nova Julia',
    shaderAsset:
        'shaders/escape_time_family/families/nova/julia_sets/nova_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      catalogPreset(
        id: 'nova-julia-classic',
        moduleId: 'nova_julia',
        name: 'Nova Classic',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.5, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'nova-julia-spiral',
        moduleId: 'nova_julia',
        name: 'Nova Spiral',
        params: {'iterations': 300, 'bailout': 4.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 3.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fatou',
    name: 'Fatou Set',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/fatou_gpu.frag',
    defaultIterations: 180,
  ),
  EscapeTimeConfig(
    id: 'gamma_fractal',
    name: 'Gamma Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/gamma_gpu.frag',
    defaultIterations: 100,
  ),
];

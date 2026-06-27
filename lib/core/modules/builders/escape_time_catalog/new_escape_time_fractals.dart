part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _newEscapeTimeFractalsCatalog = [
// ── New escape-time fractals (add shader + entry) ───────
// Uncomment as shaders are implemented:
//
  EscapeTimeConfig(
    id: 'perpendicular_mandelbrot',
    name: 'Perpendicular Mandelbrot',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'perp-mandel-relief',
        moduleId: 'perpendicular_mandelbrot',
        name: 'Stone Fold',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'lambda',
    name: 'Lambda Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/lambda_gpu.frag',
    defaultIterations: 120,
    defaultCenterX: 0.3,
    defaultCenterY: 0.3,
    defaultZoom: 0.5,
    extraPresets: [
      catalogPreset(
        id: 'lambda-relief',
        moduleId: 'lambda',
        name: 'Lambda Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_1',
    name: 'Magnet Fractal (Type I)',
    shaderAsset:
        'shaders/escape_time_family/newton_and_orthogonal/magnet_maps/magnet1_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'magnet1-relief',
        moduleId: 'magnet_type_1',
        name: 'Magnet Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(1.0, 0.0), zoom: 1.2, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_2',
    name: 'Magnet Fractal (Type II)',
    shaderAsset:
        'shaders/escape_time_family/newton_and_orthogonal/magnet_maps/magnet2_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'magnet2-relief',
        moduleId: 'magnet_type_2',
        name: 'Magnet II Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_3',
    name: 'Magnet Fractal (Type III)',
    shaderAsset:
        'shaders/escape_time_family/newton_and_orthogonal/magnet_maps/magnet3_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'magnet3-relief',
        moduleId: 'magnet_type_3',
        name: 'Rational Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'power_sum',
    name: 'Power Sum Fractal',
    shaderAsset:
        'shaders/escape_time_family/polynomial_maps/power_sum_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      catalogPreset(
        id: 'power-sum-relief',
        moduleId: 'power_sum',
        name: 'Power Sum Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cactus',
    name: 'Cactus Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/cactus_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'cactus-relief',
        moduleId: 'cactus',
        name: 'Cactus Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'astroid',
    name: 'Astroid Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/astroid_gpu.frag',
    defaultIterations: 160,
    defaultCenterX: 0.4,
    defaultCenterY: 0.0,
    defaultZoom: 0.4,
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
    shaderAsset:
        'shaders/escape_time_family/polynomial_maps/eisenstein_gpu.frag',
    defaultIterations: 170,
    defaultCenterX: 0.0,
    defaultCenterY: 3.0,
    defaultZoom: 0.3,
  ),
  EscapeTimeConfig(
    id: 'druid',
    name: 'Druid Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/druid_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'druid-relief',
        moduleId: 'druid',
        name: 'Druid Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'inverse_mandelbrot',
    name: 'Inverse Mandelbrot',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/inverse_mandelbrot_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      catalogPreset(
        id: 'inverse-mandelbrot-relief',
        moduleId: 'inverse_mandelbrot',
        name: 'Inverse Mandelbrot Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'glynn',
    name: 'Glynn Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/glynn_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'glynn-relief',
        moduleId: 'glynn',
        name: 'Glynn Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'simonbrot',
    name: 'Simonbrot',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/iterative_maps/simonbrot_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'simonbrot-relief',
        moduleId: 'simonbrot',
        name: 'Simonbrot Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'shark_fin',
    name: 'Shark Fin',
    shaderAsset:
        'shaders/escape_time_family/polynomial_maps/shark_fin_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'shark-fin-relief',
        moduleId: 'shark_fin',
        name: 'Shark Fin Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manowar',
    name: 'Manowar Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/manowar_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'manowar-relief',
        moduleId: 'manowar',
        name: 'Manowar Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'spider',
    name: 'Spider Fractal',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/coupled_orbits/spider_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'spider-relief',
        moduleId: 'spider',
        name: 'Spider Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'collatz',
    name: 'Collatz Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/collatz_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      catalogPreset(
        id: 'collatz-relief',
        moduleId: 'collatz',
        name: 'Collatz Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'popcorn',
    name: 'Popcorn Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/popcorn_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'talis',
    name: 'Talis Fractal',
    shaderAsset: 'shaders/escape_time_family/polynomial_maps/talis_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      catalogPreset(
        id: 'talis-relief',
        moduleId: 'talis',
        name: 'Talis Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tetration',
    name: 'Tetration Fractal',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/exponential_iteration/tetration_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      catalogPreset(
        id: 'tetration-relief',
        moduleId: 'tetration',
        name: 'Tetration Relief',
        params: {'iterations': 130, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
      ),
    ],
  ),
];

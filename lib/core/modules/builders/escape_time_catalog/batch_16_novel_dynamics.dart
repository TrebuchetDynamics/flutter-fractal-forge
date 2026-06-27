part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _batch16NovelDynamicsCatalog = [
// ── Batch 16 extras: novel dynamics ────────────────────────────────────
  EscapeTimeConfig(
    id: 'mandelpinski',
    name: 'Mandelpinski Necklaces',
    shaderAsset:
        'shaders/escape_time_family/mandelbrot_variants/singular_perturbations/mandelpinski_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 8.0,
    extraPresets: [
      catalogPreset(
        id: 'mandelpinski-necklace',
        moduleId: 'mandelpinski',
        name: 'Necklace Ring',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.35, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'mandelpinski-relief',
        moduleId: 'mandelpinski',
        name: 'Necklace Relief',
        params: {'iterations': 200, 'bailout': 8.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.35, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'blaschke',
    name: 'Blaschke Product',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/blaschke_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      catalogPreset(
        id: 'blaschke-cantor',
        moduleId: 'blaschke',
        name: 'Cantor Circles',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'blaschke-relief',
        moduleId: 'blaschke',
        name: 'Blaschke Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fatou_exp',
    name: 'Fatou Exponential',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/fatou_exp_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 50.0,
    extraPresets: [
      catalogPreset(
        id: 'fatou-exp-spiral',
        moduleId: 'fatou_exp',
        name: 'Spiral Arms',
        params: {'iterations': 120, 'bailout': 50.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.3, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'fatou-exp-relief',
        moduleId: 'fatou_exp',
        name: 'Fatou Relief',
        params: {'iterations': 150, 'bailout': 50.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.3, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sin_z2',
    name: 'sin(z²) + c',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/sin_z2_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 20.0,
    extraPresets: [
      catalogPreset(
        id: 'sin-z2-quad',
        moduleId: 'sin_z2',
        name: 'Quad Symmetry',
        params: {'iterations': 150, 'bailout': 20.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'sin-z2-relief',
        moduleId: 'sin_z2',
        name: 'sin(z²) Relief',
        params: {'iterations': 200, 'bailout': 20.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
      ),
    ],
  ),
];

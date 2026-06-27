part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _batch17WeierstrassSteffensenCatalog = [
// ── Batch 17: Weierstrass & Steffensen ──────────────────────────────────

  EscapeTimeConfig(
    id: 'weierstrass_p',
    name: 'Weierstrass ℘ + c',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/special_functions/weierstrass_p_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 8.0,
    extraPresets: [
      catalogPreset(
        id: 'wp-classic',
        moduleId: 'weierstrass_p',
        name: 'Square Lattice',
        params: {'iterations': 120, 'bailout': 8.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'wp-relief',
        moduleId: 'weierstrass_p',
        name: '℘ Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.4, rotation: Vector3.zero()),
      ),
    ],
  ),

  EscapeTimeConfig(
    id: 'weierstrass_roots',
    name: 'Weierstrass Roots',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/special_functions/weierstrass_roots_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'wroots-basins',
        moduleId: 'weierstrass_roots',
        name: 'Three Basins',
        params: {'iterations': 80, 'bailout': 4.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.6, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'wroots-relief',
        moduleId: 'weierstrass_roots',
        name: 'Weierstrass Relief',
        params: {'iterations': 100, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.6, rotation: Vector3.zero()),
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
      catalogPreset(
        id: 'steff3-trefoil',
        moduleId: 'steffensen_z3',
        name: 'Trefoil Basins',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'steff3-golden',
        moduleId: 'steffensen_z3',
        name: 'Golden Ornaments',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 5},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
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
      catalogPreset(
        id: 'steff4-cross',
        moduleId: 'steffensen_z4',
        name: 'Cross Basins',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'steff4-sapphire',
        moduleId: 'steffensen_z4',
        name: 'Sapphire Quatrefoil',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 4},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
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
      catalogPreset(
        id: 'steff5-penta',
        moduleId: 'steffensen_z5',
        name: 'Pentagonal Basins',
        params: {'iterations': 100, 'bailout': 8.0, 'colorScheme': 2},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
      ),
      catalogPreset(
        id: 'steff5-fire',
        moduleId: 'steffensen_z5',
        name: 'Fire Pentagon',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 6},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 0.5, rotation: Vector3.zero()),
      ),
    ],
  ),
];

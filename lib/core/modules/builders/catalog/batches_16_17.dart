import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// Batches 16-17: Novel Dynamics and Weierstrass & Steffensen.
///
/// Recent additions including:
/// - Batch 16: Novel dynamical systems (Mandelpinski, etc.)
/// - Batch 17: Weierstrass elliptic and Steffensen iterations

final List<EscapeTimeConfig> batches16_17Entries = [
  EscapeTimeConfig(
    id: 'mandelpinski',
    name: 'Mandelpinski Necklaces',
    shaderAsset: 'shaders/mandelpinski_gpu.frag',
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
    shaderAsset: 'shaders/blaschke_gpu.frag',
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
    shaderAsset: 'shaders/fatou_exp_gpu.frag',
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
    shaderAsset: 'shaders/sin_z2_gpu.frag',
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
    shaderAsset: 'shaders/weierstrass_p_gpu.frag',
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
    shaderAsset: 'shaders/weierstrass_roots_gpu.frag',
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
    shaderAsset: 'shaders/steffensen_z3_gpu.frag',
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
    shaderAsset: 'shaders/steffensen_z4_gpu.frag',
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
    shaderAsset: 'shaders/steffensen_z5_gpu.frag',
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
];

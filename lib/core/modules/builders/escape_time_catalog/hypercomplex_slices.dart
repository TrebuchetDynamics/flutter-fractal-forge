part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _hypercomplexSlicesCatalog = [
// ── III. Hypercomplex / Higher-dimensional slices ─────
  EscapeTimeConfig(
    id: 'quaternion_julia_2d',
    name: 'Quaternion Julia (2D Slice)',
    shaderAsset:
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/quaternion_julia_2d_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8.0,
    extraPresets: [
      catalogPreset(
        id: 'quaternion_julia_2d-relief',
        moduleId: 'quaternion_julia_2d',
        name: 'Quaternion Relief',
        params: {'iterations': 160, 'bailout': 8.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tessarine_julia',
    name: 'Tessarine Julia',
    shaderAsset:
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/tessarine_julia_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8.0,
    extraPresets: [
      catalogPreset(
        id: 'tessarine_julia-relief',
        moduleId: 'tessarine_julia',
        name: 'Tessarine Relief',
        params: {'iterations': 160, 'bailout': 8.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'split_complex',
    name: 'Split-Complex Fractal',
    shaderAsset:
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/split_complex_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 10.0,
    extraPresets: [
      catalogPreset(
        id: 'split_complex-relief',
        moduleId: 'split_complex',
        name: 'Split-Complex Relief',
        params: {'iterations': 180, 'bailout': 10.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'dual_complex',
    name: 'Dual-Complex Fractal',
    shaderAsset:
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/dual_complex_gpu.frag',
    defaultIterations: 170,
    defaultBailout: 10.0,
  ),
  EscapeTimeConfig(
    id: 'bicomplex',
    name: 'Bicomplex Mandelbrot',
    shaderAsset:
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/bicomplex_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 12.0,
    extraPresets: [
      catalogPreset(
        id: 'bicomplex-relief',
        moduleId: 'bicomplex',
        name: 'Bicomplex Relief',
        params: {'iterations': 180, 'bailout': 12.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
];

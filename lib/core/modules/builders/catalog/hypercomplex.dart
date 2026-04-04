import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// Hypercomplex and Higher-dimensional Slice Fractals.
///
/// 2D slices of higher-dimensional fractals including Quaternion Julia,
/// Bicomplex, and other hypercomplex variants.

final List<EscapeTimeConfig> hypercomplexEntries = [
  EscapeTimeConfig(
    id: 'quaternion_julia_2d',
    name: 'Quaternion Julia (2D Slice)',
    shaderAsset: 'shaders/quaternion_julia_2d_gpu.frag',
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
    shaderAsset: 'shaders/tessarine_julia_gpu.frag',
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
    shaderAsset: 'shaders/split_complex_gpu.frag',
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
];

import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// Trigonometric Fractals.
///
/// Fractals based on trigonometric and hyperbolic functions
/// including sine, cosine, and tangent Julia variants.

final List<EscapeTimeConfig> trigonometricEntries = [
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
    shaderAsset: 'shaders/cosine_julia_gpu.frag',
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
    shaderAsset: 'shaders/tangent_gpu.frag',
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
    shaderAsset: 'shaders/sinh_cosh_gpu.frag',
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
    shaderAsset: 'shaders/exponential_gpu.frag',
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
    shaderAsset: 'shaders/zircon_zity_gpu.frag',
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
];

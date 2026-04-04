import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';

/// Convergent and Root-Finding Fractals.
///
/// Fractals based on root-finding algorithms including Newton,
/// Halley, and Householder methods.

final List<EscapeTimeConfig> convergentRootFindingEntries = [
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
];

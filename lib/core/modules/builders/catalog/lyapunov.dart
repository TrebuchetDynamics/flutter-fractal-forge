import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';

/// Lyapunov Fractals.
///
/// Fractals based on Lyapunov exponents and stability analysis
/// of dynamical systems.

final List<EscapeTimeConfig> lyapunovEntries = [
  EscapeTimeConfig(
    id: 'lyapunov',
    name: 'Lyapunov Fractal',
    shaderAsset: 'shaders/lyapunov_gpu.frag',
    defaultIterations: 200,
    defaultCenterX: 3.0,
    defaultCenterY: 3.0,
  ),
  EscapeTimeConfig(
    id: 'logistic_lyapunov',
    name: 'Logistic Lyapunov',
    shaderAsset: 'shaders/logistic_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 3.0,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'circle_map_lyapunov',
    name: 'Circle Map Lyapunov',
    shaderAsset: 'shaders/circle_map_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.0,
    defaultCenterY: 1.0,
  ),
  EscapeTimeConfig(
    id: 'sine_map_lyapunov',
    name: 'Sine Map Lyapunov',
    shaderAsset: 'shaders/sine_map_lyapunov_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.85,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'tent_map',
    name: 'Tent Map',
    shaderAsset: 'shaders/tent_map_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 1.0,
    defaultCenterY: 0.5,
  ),
  EscapeTimeConfig(
    id: 'hopalong',
    name: 'Hopalong Attractor',
    shaderAsset: 'shaders/hopalong_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 32.0,
  ),
  EscapeTimeConfig(
    id: 'pickover_biomorph',
    name: 'Pickover Biomorph',
    shaderAsset: 'shaders/pickover_gpu.frag',
    defaultIterations: 220,
    defaultBailout: 64.0,
  ),
  EscapeTimeConfig(
    id: 'feigenbaum',
    name: 'Feigenbaum Logistic Map',
    shaderAsset: 'shaders/feigenbaum_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: 0.25,
    defaultCenterY: 0.0,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'gauss_map',
    name: 'Gauss Map',
    shaderAsset: 'shaders/gauss_map_gpu.frag',
    defaultIterations: 220,
    defaultCenterX: 0.0,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'buddhabrot_approx',
    name: 'Buddhabrot (Approx)',
    shaderAsset: 'shaders/buddhabrot_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'anti_buddhabrot',
    name: 'Anti-Buddhabrot',
    shaderAsset: 'shaders/anti_buddhabrot_gpu.frag',
    defaultIterations: 260,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
  EscapeTimeConfig(
    id: 'nebulabrot',
    name: 'Nebulabrot (Approx)',
    shaderAsset: 'shaders/nebulabrot_gpu.frag',
    defaultIterations: 280,
    defaultCenterX: -0.5,
    defaultCenterY: 0.0,
    defaultBailout: 8.0,
  ),
];

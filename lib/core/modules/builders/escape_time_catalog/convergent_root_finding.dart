part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _convergentRootFindingCatalog = [
// ── II. Convergent/Root-Finding (escape-time variant) ───
  EscapeTimeConfig(
    id: 'newton_z3',
    name: 'Newton Fractal (z³ - 1)',
    shaderAsset: 'shaders/root_finding/newton_z3_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'halley',
    name: "Halley's Fractal",
    shaderAsset: 'shaders/root_finding/halley_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'householder',
    name: 'Householder Fractal',
    shaderAsset: 'shaders/root_finding/householder_gpu.frag',
    defaultIterations: 80,
    defaultBailout: 4.0,
    extraParams: [
      FractalParameter(
        id: 'relaxation',
        label: (_) => 'Relaxation',
        type: FractalParamType.float,
        min: 0.1,
        max: 2.0,
        step: 0.01,
        defaultValue: 1.0,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'zeta_newton',
    name: 'Riemann Zeta Newton Basins',
    shaderAsset: 'shaders/root_finding/zeta_newton_gpu.frag',
    defaultIterations: 60,
    defaultBailout: 4.0,
    // Framed on the critical line: Re(s) = 1/2, with the first nontrivial
    // zeros at Im(s) ~ 14.13, 21.02, 25.01.
    defaultCenterX: 0.5,
    defaultCenterY: 16.0,
    defaultZoom: 0.06,
    extraParams: [
      FractalParameter(
        id: 'terms',
        label: (_) => 'Series Terms',
        type: FractalParamType.float,
        min: 8,
        max: 48,
        step: 1,
        defaultValue: 28,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_newton',
    name: 'Magnet Newton',
    shaderAsset: 'shaders/root_finding/magnet_newton_gpu.frag',
    defaultIterations: 90,
    defaultBailout: 6.0,
  ),
  EscapeTimeConfig(
    id: 'hypercomplex_newton',
    name: 'Hypercomplex Newton (Quaternion z³ - 1)',
    shaderAsset:
        'shaders/3d_and_hypercomplex/hypercomplex_escape_time/hypercomplex_newton_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 8.0,
  ),
];

part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _trigonometricCatalog = [
// ── VII. Trigonometric ──────────────────────────────────
  EscapeTimeConfig(
    id: 'sine_julia',
    name: 'Sine Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/sine_julia_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'sine-julia-relief',
        moduleId: 'sine_julia',
        name: 'Sine Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosine_julia',
    name: 'Cosine Julia',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/cosine_julia_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'cosine-julia-relief',
        moduleId: 'cosine_julia',
        name: 'Cosine Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent',
    name: 'Tangent Fractal',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/tangent_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      catalogPreset(
        id: 'tangent-relief',
        moduleId: 'tangent',
        name: 'Tangent Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_cosh',
    name: 'Sinh Fractal',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/sinh_cosh_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      catalogPreset(
        id: 'sinh-cosh-relief',
        moduleId: 'sinh_cosh',
        name: 'Sinh Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'exponential',
    name: 'Exponential Fractal',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/exponential_iteration/exponential_gpu.frag',
    defaultIterations: 100,
    extraPresets: [
      catalogPreset(
        id: 'exponential-relief',
        moduleId: 'exponential',
        name: 'Exponential Relief',
        params: {'iterations': 150, 'bailout': 8.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'zircon_zity',
    name: 'Zircon Zity',
    shaderAsset:
        'shaders/escape_time_family/polynomial_maps/zircon_zity_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      catalogPreset(
        id: 'zircon-zity-relief',
        moduleId: 'zircon_zity',
        name: 'Zircon Zity Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
];

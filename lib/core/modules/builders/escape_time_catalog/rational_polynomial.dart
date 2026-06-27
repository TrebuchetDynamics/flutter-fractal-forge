part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _rationalPolynomialCatalog = [
// ── VIII. Advanced Rational & Polynomial ─────────────────
  EscapeTimeConfig(
    id: 'barnsley_j1',
    name: "Barnsley J1",
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_j1_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      catalogPreset(
        id: 'barnsley-j1-relief',
        moduleId: 'barnsley_j1',
        name: 'Barnsley J1 Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fish',
    name: 'Fish Fractal',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/discrete_attractors/fish_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      catalogPreset(
        id: 'fish-relief',
        moduleId: 'fish',
        name: 'Fish Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'ducky',
    name: 'Ducky Fractal',
    shaderAsset:
        'shaders/escape_time_family/experimental_named/discrete_attractors/ducky_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      catalogPreset(
        id: 'ducky-relief',
        moduleId: 'ducky',
        name: 'Ducky Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'schroeder',
    name: "Schröder's Fractal",
    shaderAsset: 'shaders/root_finding/schroeder_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_fractal',
    name: 'Secant Fractal',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/secant_fractal_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_cosecant',
    name: 'Secant/Cosecant Map',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/secant_cosecant_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 12.0,
  ),

  EscapeTimeConfig(
    id: 'taylor',
    name: 'Taylor Series Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/taylor_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'rational_map',
    name: 'Rational Map Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/rational_map_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      catalogPreset(
        id: 'rational_map-relief',
        moduleId: 'rational_map',
        name: 'Rational Map Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'lattes_map_julia',
    name: 'Lattès Map Julia Set',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/lattes_map_julia_gpu.frag',
    defaultIterations: 180,
    defaultBailout: 64.0,
    category: 'Complex Dynamics',
  ),
  EscapeTimeConfig(
    id: 'complex_henon_julia_slice',
    name: 'Complex Hénon Julia Slice',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/complex_henon_julia_slice_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 16.0,
    category: 'Complex Dynamics',
    extraParams: [
      _floatParam(
        id: 'a',
        label: 'A',
        min: 0,
        max: 1,
        step: 0.05,
        defaultValue: 0.3,
      ),
      _floatParam(
        id: 'cReal',
        label: 'C Real',
        min: -2,
        max: 2,
        step: 0.05,
        defaultValue: -0.65,
      ),
      _floatParam(
        id: 'cImag',
        label: 'C Imag',
        min: -2,
        max: 2,
        step: 0.05,
        defaultValue: 0.35,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'matrix_logistic_spectrum',
    name: 'Matrix Logistic Spectrum',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/matrix_logistic_spectrum_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 16.0,
    category: 'Spectral Fractals',
    extraParams: [
      _floatParam(
        id: 'r',
        label: 'R',
        min: 0,
        max: 4,
        step: 0.05,
        defaultValue: 3.8,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j2',
    name: 'Barnsley J2',
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_j2_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      catalogPreset(
        id: 'barnsley_j2-relief',
        moduleId: 'barnsley_j2',
        name: 'Barnsley J2 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 63},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j3',
    name: 'Barnsley J3',
    shaderAsset: 'shaders/ifs_and_geometric/barnsley_j3_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      catalogPreset(
        id: 'barnsley_j3-relief',
        moduleId: 'barnsley_j3',
        name: 'Barnsley J3 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'celtic_julia',
    name: 'Celtic Julia',
    shaderAsset:
        'shaders/escape_time_family/families/celtic/celtic_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      catalogPreset(
        id: 'celtic-julia-relief',
        moduleId: 'celtic_julia',
        name: 'Ember Knot',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_julia',
    name: 'Buffalo Julia',
    shaderAsset:
        'shaders/escape_time_family/families/buffalo/buffalo_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      catalogPreset(
        id: 'buffalo-julia-relief',
        moduleId: 'buffalo_julia',
        name: 'Herd Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perpendicular_julia',
    name: 'Perpendicular Julia',
    shaderAsset:
        'shaders/escape_time_family/families/perpendicular/perpendicular_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      catalogPreset(
        id: 'perp-julia-relief',
        moduleId: 'perpendicular_julia',
        name: 'Mirror Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_julia',
    name: 'Tricorn Julia',
    shaderAsset:
        'shaders/escape_time_family/families/tricorn/julia_sets/tricorn_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      catalogPreset(
        id: 'tricorn-julia-relief',
        moduleId: 'tricorn_julia',
        name: 'Horn Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_julia',
    name: 'Burning Ship Julia',
    shaderAsset:
        'shaders/escape_time_family/families/burning_ship/julia_sets/burning_ship_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      catalogPreset(
        id: 'ship-julia-relief',
        moduleId: 'burning_ship_julia',
        name: 'Flame Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_neg2',
    name: 'Multibrot d=-2',
    shaderAsset:
        'shaders/escape_time_family/families/multibrot/multibrot_neg2_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'heart',
    name: 'Heart Fractal',
    shaderAsset: 'shaders/escape_time_family/julia_variants/heart_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'cosine_mandelbrot',
    name: 'Cosine Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    // z_{n+1}=cos(z)+c is mostly bounded near c≈0. Centering at (0,0) with
    // zoom=1 often looks fully black. Start wider and slightly left to reveal
    // escape structure immediately.
    defaultCenterX: -0.4,
    defaultZoom: 0.3,
    extraParams: [
      FractalParameter(
        id: 'variant',
        label: (_) => 'Variant',
        type: FractalParamType.integer,
        min: 0,
        max: 4,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'cosine-mandel-relief',
        moduleId: 'cosine_mandelbrot',
        name: 'Cosine Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.4, 0.0), zoom: 0.3, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent_mandelbrot',
    name: 'Tangent Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/elementary_trig/tangent_mandelbrot_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 4.0,
    extraParams: [
      FractalParameter(
        id: 'variant',
        label: (_) => 'Variant',
        type: FractalParamType.integer,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'tangent-mandel-relief',
        moduleId: 'tangent_mandelbrot',
        name: 'Tangent Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_mandelbrot',
    name: 'Sinh Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/sinh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'sinh-mandel-relief',
        moduleId: 'sinh_mandelbrot',
        name: 'Sinh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosh_mandelbrot',
    name: 'Cosh Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/cosh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'cosh-mandel-relief',
        moduleId: 'cosh_mandelbrot',
        name: 'Cosh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tanh_mandelbrot',
    name: 'Tanh Mandelbrot',
    shaderAsset:
        'shaders/trigonometric_and_transcendental/hyperbolic/tanh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraParams: [
      FractalParameter(
        id: 'variant',
        label: (_) => 'Variant',
        type: FractalParamType.integer,
        min: 0,
        max: 2,
        step: 1,
        defaultValue: 0,
      ),
    ],
    extraPresets: [
      catalogPreset(
        id: 'tanh-mandel-relief',
        moduleId: 'tanh_mandelbrot',
        name: 'Tanh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'log_spiral',
    name: 'Log Spiral Fractal',
    shaderAsset:
        'shaders/escape_time_family/transcendental_maps/log_spiral_gpu.frag',
    defaultIterations: 140,
  ),
];

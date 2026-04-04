import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// Advanced Rational and Polynomial Fractals.
///
/// Higher-degree polynomial and rational function fractals including
/// Barnsley variants, Collatz, and other complex iterations.

final List<EscapeTimeConfig> advancedRationalEntries = [
  EscapeTimeConfig(
    id: 'barnsley_j1',
    name: "Barnsley J1",
    shaderAsset: 'shaders/barnsley_j1_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'barnsley-j1-relief',
        moduleId: 'barnsley_j1',
        name: 'Barnsley J1 Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'fish',
    name: 'Fish Fractal',
    shaderAsset: 'shaders/fish_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'fish-relief',
        moduleId: 'fish',
        name: 'Fish Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'ducky',
    name: 'Ducky Fractal',
    shaderAsset: 'shaders/ducky_gpu.frag',
    defaultIterations: 130,
    extraPresets: [
      FractalPreset(
        id: 'ducky-relief',
        moduleId: 'ducky',
        name: 'Ducky Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'schroeder',
    name: "Schröder's Fractal",
    shaderAsset: 'shaders/schroeder_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_fractal',
    name: 'Secant Fractal',
    shaderAsset: 'shaders/secant_fractal_gpu.frag',
    defaultIterations: 80,
  ),
  EscapeTimeConfig(
    id: 'secant_cosecant',
    name: 'Secant/Cosecant Map',
    shaderAsset: 'shaders/secant_cosecant_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 12.0,
  ),
  EscapeTimeConfig(
    id: 'taylor',
    name: 'Taylor Series Fractal',
    shaderAsset: 'shaders/taylor_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'rational_map',
    name: 'Rational Map Fractal',
    shaderAsset: 'shaders/rational_map_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'rational_map-relief',
        moduleId: 'rational_map',
        name: 'Rational Map Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j2',
    name: 'Barnsley J2',
    shaderAsset: 'shaders/barnsley_j2_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'barnsley_j2-relief',
        moduleId: 'barnsley_j2',
        name: 'Barnsley J2 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 63},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'barnsley_j3',
    name: 'Barnsley J3',
    shaderAsset: 'shaders/barnsley_j3_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'barnsley_j3-relief',
        moduleId: 'barnsley_j3',
        name: 'Barnsley J3 Relief',
        params: {'iterations': 140, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'celtic_julia',
    name: 'Celtic Julia',
    shaderAsset: 'shaders/celtic_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'celtic-julia-relief',
        moduleId: 'celtic_julia',
        name: 'Ember Knot',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'buffalo_julia',
    name: 'Buffalo Julia',
    shaderAsset: 'shaders/buffalo_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'buffalo-julia-relief',
        moduleId: 'buffalo_julia',
        name: 'Herd Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'perpendicular_julia',
    name: 'Perpendicular Julia',
    shaderAsset: 'shaders/perpendicular_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'perp-julia-relief',
        moduleId: 'perpendicular_julia',
        name: 'Mirror Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tricorn_julia',
    name: 'Tricorn Julia',
    shaderAsset: 'shaders/tricorn_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'tricorn-julia-relief',
        moduleId: 'tricorn_julia',
        name: 'Horn Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'burning_ship_julia',
    name: 'Burning Ship Julia',
    shaderAsset: 'shaders/burning_ship_julia_gpu.frag',
    defaultIterations: 160,
    extraPresets: [
      FractalPreset(
        id: 'ship-julia-relief',
        moduleId: 'burning_ship_julia',
        name: 'Flame Relief',
        params: {'iterations': 220, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'multibrot_neg2',
    name: 'Multibrot d=-2',
    shaderAsset: 'shaders/multibrot_neg2_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'heart',
    name: 'Heart Fractal',
    shaderAsset: 'shaders/heart_gpu.frag',
    defaultIterations: 140,
  ),
  EscapeTimeConfig(
    id: 'cosine_mandelbrot',
    name: 'Cosine Mandelbrot',
    shaderAsset: 'shaders/cosine_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    // z_{n+1}=cos(z)+c is mostly bounded near c≈0. Centering at (0,0) with
    // zoom=1 often looks fully black. Start wider and slightly left to reveal
    // escape structure immediately.
    defaultCenterX: -0.4,
    defaultZoom: 0.3,
    extraPresets: [
      FractalPreset(
        id: 'cosine-mandel-relief',
        moduleId: 'cosine_mandelbrot',
        name: 'Cosine Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(-0.4, 0.0), zoom: 0.3, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tangent_mandelbrot',
    name: 'Tangent Mandelbrot',
    shaderAsset: 'shaders/tangent_mandelbrot_gpu.frag',
    defaultIterations: 110,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tangent-mandel-relief',
        moduleId: 'tangent_mandelbrot',
        name: 'Tangent Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'sinh_mandelbrot',
    name: 'Sinh Mandelbrot',
    shaderAsset: 'shaders/sinh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'sinh-mandel-relief',
        moduleId: 'sinh_mandelbrot',
        name: 'Sinh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 54},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cosh_mandelbrot',
    name: 'Cosh Mandelbrot',
    shaderAsset: 'shaders/cosh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'cosh-mandel-relief',
        moduleId: 'cosh_mandelbrot',
        name: 'Cosh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tanh_mandelbrot',
    name: 'Tanh Mandelbrot',
    shaderAsset: 'shaders/tanh_mandelbrot_gpu.frag',
    defaultIterations: 120,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'tanh-mandel-relief',
        moduleId: 'tanh_mandelbrot',
        name: 'Tanh Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 60},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'log_spiral',
    name: 'Log Spiral Fractal',
    shaderAsset: 'shaders/log_spiral_gpu.frag',
    defaultIterations: 140,
  ),
];

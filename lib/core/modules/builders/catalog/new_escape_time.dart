import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:vector_math/vector_math.dart';

/// New escape-time fractal additions.
///
/// Recently added escape-time fractals with modern shader implementations.

final List<EscapeTimeConfig> newEscapeTimeEntries = [
  EscapeTimeConfig(
    id: 'perpendicular_mandelbrot',
    name: 'Perpendicular Mandelbrot',
    shaderAsset: 'shaders/perpendicular_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'perp-mandel-relief',
        moduleId: 'perpendicular_mandelbrot',
        name: 'Stone Fold',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'lambda',
    name: 'Lambda Fractal',
    shaderAsset: 'shaders/lambda_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'lambda-relief',
        moduleId: 'lambda',
        name: 'Lambda Relief',
        params: {'iterations': 180, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_1',
    name: 'Magnet Fractal (Type I)',
    shaderAsset: 'shaders/magnet1_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet1-relief',
        moduleId: 'magnet_type_1',
        name: 'Magnet Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 52},
        view: FractalViewState(
            pan: Vector2(1.0, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_2',
    name: 'Magnet Fractal (Type II)',
    shaderAsset: 'shaders/magnet2_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet2-relief',
        moduleId: 'magnet_type_2',
        name: 'Magnet II Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(1.0, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'magnet_type_3',
    name: 'Magnet Fractal (Type III)',
    shaderAsset: 'shaders/magnet3_gpu.frag',
    defaultIterations: 100,
    defaultBailout: 4.0,
    extraPresets: [
      FractalPreset(
        id: 'magnet3-relief',
        moduleId: 'magnet_type_3',
        name: 'Rational Relief',
        params: {'iterations': 150, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'power_sum',
    name: 'Power Sum Fractal',
    shaderAsset: 'shaders/power_sum_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'power-sum-relief',
        moduleId: 'power_sum',
        name: 'Power Sum Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 59},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'cactus',
    name: 'Cactus Fractal',
    shaderAsset: 'shaders/cactus_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'cactus-relief',
        moduleId: 'cactus',
        name: 'Cactus Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 62},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'astroid',
    name: 'Astroid Fractal',
    shaderAsset: 'shaders/astroid_gpu.frag',
    defaultIterations: 160,
  ),
  EscapeTimeConfig(
    id: 'deltoid',
    name: 'Deltoid Fractal',
    shaderAsset: 'shaders/deltoid_gpu.frag',
    defaultIterations: 150,
  ),
  EscapeTimeConfig(
    id: 'eisenstein',
    name: 'Eisenstein Fractal',
    shaderAsset: 'shaders/eisenstein_gpu.frag',
    defaultIterations: 170,
  ),
  EscapeTimeConfig(
    id: 'druid',
    name: 'Druid Fractal',
    shaderAsset: 'shaders/druid_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'druid-relief',
        moduleId: 'druid',
        name: 'Druid Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 53},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'inverse_mandelbrot',
    name: 'Inverse Mandelbrot',
    shaderAsset: 'shaders/inverse_mandelbrot_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'inverse-mandelbrot-relief',
        moduleId: 'inverse_mandelbrot',
        name: 'Inverse Mandelbrot Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'glynn',
    name: 'Glynn Fractal',
    shaderAsset: 'shaders/glynn_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'glynn-relief',
        moduleId: 'glynn',
        name: 'Glynn Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 50},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'simonbrot',
    name: 'Simonbrot',
    shaderAsset: 'shaders/simonbrot_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'simonbrot-relief',
        moduleId: 'simonbrot',
        name: 'Simonbrot Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 55},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'shark_fin',
    name: 'Shark Fin',
    shaderAsset: 'shaders/shark_fin_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'shark-fin-relief',
        moduleId: 'shark_fin',
        name: 'Shark Fin Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 51},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'manowar',
    name: 'Manowar Fractal',
    shaderAsset: 'shaders/manowar_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'manowar-relief',
        moduleId: 'manowar',
        name: 'Manowar Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 57},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'spider',
    name: 'Spider Fractal',
    shaderAsset: 'shaders/spider_gpu.frag',
    defaultIterations: 150,
    extraPresets: [
      FractalPreset(
        id: 'spider-relief',
        moduleId: 'spider',
        name: 'Spider Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'collatz',
    name: 'Collatz Fractal',
    shaderAsset: 'shaders/collatz_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'collatz-relief',
        moduleId: 'collatz',
        name: 'Collatz Relief',
        params: {'iterations': 160, 'bailout': 4.0, 'colorScheme': 56},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'popcorn',
    name: 'Popcorn Fractal',
    shaderAsset: 'shaders/popcorn_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 4.0,
  ),
  EscapeTimeConfig(
    id: 'talis',
    name: 'Talis Fractal',
    shaderAsset: 'shaders/talis_gpu.frag',
    defaultIterations: 140,
    extraPresets: [
      FractalPreset(
        id: 'talis-relief',
        moduleId: 'talis',
        name: 'Talis Relief',
        params: {'iterations': 200, 'bailout': 4.0, 'colorScheme': 58},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
  EscapeTimeConfig(
    id: 'tetration',
    name: 'Tetration Fractal',
    shaderAsset: 'shaders/tetration_gpu.frag',
    defaultIterations: 120,
    extraPresets: [
      FractalPreset(
        id: 'tetration-relief',
        moduleId: 'tetration',
        name: 'Tetration Relief',
        params: {'iterations': 130, 'bailout': 4.0, 'colorScheme': 61},
        view: FractalViewState(
            pan: Vector2(-0.5, 0.0), zoom: 1.2, rotation: Vector3.zero()),
        createdAt: DateTime.now(),
        isBuiltIn: true,
      ),
    ],
  ),
];

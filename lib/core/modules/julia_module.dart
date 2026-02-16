import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildJuliaModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: 5000,
      step: 1,
      defaultValue: 160,
    ),
    FractalParameter(
      id: 'bailout',
      label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float,
      min: 2.0,
      max: 8.0,
      step: 0.1,
      defaultValue: 4.0,
    ),
    CommonFractalParams.colorScheme64(defaultValue: 0),
    FractalParameter(
      id: 'juliaCReal',
      label: (l10n) => l10n.paramJuliaCReal,
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.01,
      defaultValue: -0.8,
    ),
    FractalParameter(
      id: 'juliaCImag',
      label: (l10n) => l10n.paramJuliaCImag,
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.01,
      defaultValue: 0.156,
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'julia-default',
    moduleId: 'julia',
    name: 'Default',
    params: {
      'iterations': 160,
      'bailout': 4.0,
      'colorScheme': 0,
      'juliaCReal': -0.8,
      'juliaCImag': 0.156,
    },
    view: FractalViewState.initial(),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'julia',
    displayName: (l10n) => l10n.moduleJulia,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/julia_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'julia-classic', name: 'Classic'),
      // Dendrite - branching lightning patterns
      defaultPreset.copyWith(
        id: 'julia-dendrite',
        name: 'Dendrite',
        params: {
          'iterations': 280,
          'bailout': 4.0,
          'colorScheme': 3, // Grayscale
          'juliaCReal': 0.0,
          'juliaCImag': 1.0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.2,
          rotation: Vector3.zero(),
        ),
      ),
      // Spiral Galaxy - beautiful spiral arms
      defaultPreset.copyWith(
        id: 'julia-galaxy',
        name: 'Spiral Galaxy',
        params: {
          'iterations': 300,
          'bailout': 4.0,
          'colorScheme': 2, // Psychedelic
          'juliaCReal': -0.7269,
          'juliaCImag': 0.1889,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
      ),
      // Dragon's Breath - fiery swirling patterns
      defaultPreset.copyWith(
        id: 'julia-dragon',
        name: "Dragon's Breath",
        params: {
          'iterations': 250,
          'bailout': 4.5,
          'colorScheme': 0, // Fire
          'juliaCReal': -0.835,
          'juliaCImag': -0.2321,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3.zero(),
        ),
      ),
      // San Marco - famous Julia set pattern
      defaultPreset.copyWith(
        id: 'julia-sanmarco',
        name: 'San Marco',
        params: {
          'iterations': 320,
          'bailout': 4.0,
          'colorScheme': 1, // Ocean
          'juliaCReal': -0.75,
          'juliaCImag': 0.0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.4,
          rotation: Vector3.zero(),
        ),
      ),
      // Siegel Disk - circular patterns with intricate borders
      defaultPreset.copyWith(
        id: 'julia-siegel',
        name: 'Siegel Disk',
        params: {
          'iterations': 350,
          'bailout': 4.0,
          'colorScheme': 2, // Psychedelic
          'juliaCReal': -0.391,
          'juliaCImag': -0.587,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.6,
          rotation: Vector3.zero(),
        ),
      ),
      // Rabbit - resembles a rabbit's silhouette
      defaultPreset.copyWith(
        id: 'julia-rabbit',
        name: 'Douady Rabbit',
        params: {
          'iterations': 280,
          'bailout': 4.0,
          'colorScheme': 0, // Fire
          'juliaCReal': -0.123,
          'juliaCImag': 0.745,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.3,
          rotation: Vector3.zero(),
        ),
      ),
      // Electric Storm - high energy chaotic patterns
      defaultPreset.copyWith(
        id: 'julia-storm',
        name: 'Electric Storm',
        params: {
          'iterations': 220,
          'bailout': 3.5,
          'colorScheme': 2, // Psychedelic
          'juliaCReal': -0.4,
          'juliaCImag': 0.6,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Coral Reef - organic underwater patterns
      defaultPreset.copyWith(
        id: 'julia-coral',
        name: 'Coral Reef',
        params: {
          'iterations': 300,
          'bailout': 5.0,
          'colorScheme': 1, // Ocean
          'juliaCReal': 0.285,
          'juliaCImag': 0.01,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final iterations = _readDouble(state.params, 'iterations', 160);
      final bailout = _readDouble(state.params, 'bailout', 4.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 0);
      final juliaCReal = _readDouble(state.params, 'juliaCReal', -0.8);
      final juliaCImag = _readDouble(state.params, 'juliaCImag', 0.156);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations);
      shader.setFloat(7, bailout);
      shader.setFloat(8, colorScheme);
      shader.setFloat(9, juliaCReal);
      shader.setFloat(10, juliaCImag);
      shader.setFloat(11, state.transparentBackground ? 1.0 : 0.0);

      // GPU-safe: no custom palette uniform block in julia_gpu.frag
    },
  );
}

double _readDouble(Map<String, Object> params, String key, double fallback) {
  final value = params[key];
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  return fallback;
}

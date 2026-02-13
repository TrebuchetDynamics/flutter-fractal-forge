import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

/// The Phoenix fractal is a variation of the Julia set with a "memory" term.
/// 
/// Formula: z(n+1) = z(n)^2 + c + p * z(n-1)
/// 
/// The parameter p adds a "memory" of the previous iteration, creating
/// beautiful asymmetric patterns that resemble rising flames or wings.
FractalModule buildPhoenixModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: 500,
      step: 1,
      defaultValue: 180,
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
    // Keep Phoenix palette as default (index 4), then 5..63 are numbered palettes.
    CommonFractalParams.colorScheme64(defaultValue: 4),
    FractalParameter(
      id: 'phoenixCReal',
      label: (l10n) => l10n.paramPhoenixCReal,
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.01,
      defaultValue: 0.5667,
    ),
    FractalParameter(
      id: 'phoenixCImag',
      label: (l10n) => l10n.paramPhoenixCImag,
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.01,
      defaultValue: 0.0,
    ),
    FractalParameter(
      id: 'phoenixP',
      label: (l10n) => l10n.paramPhoenixP,
      type: FractalParamType.float,
      min: -1.0,
      max: 1.0,
      step: 0.01,
      defaultValue: -0.5,
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'phoenix-default',
    moduleId: 'phoenix',
    name: 'Default',
    params: {
      'iterations': 180,
      'bailout': 4.0,
      'colorScheme': 4,
      'phoenixCReal': 0.5667,
      'phoenixCImag': 0.0,
      'phoenixP': -0.5,
    },
    view: FractalViewState(
      pan: Vector2(-0.5, 0.0),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'phoenix',
    displayName: (l10n) => l10n.modulePhoenix,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/phoenix_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'phoenix-classic', name: 'Classic'),
      // Phoenix Rising - iconic upward flames
      defaultPreset.copyWith(
        id: 'phoenix-rising',
        name: 'Rising',
        params: {
          'iterations': 280,
          'bailout': 4.0,
          'colorScheme': 0, // Fire
          'phoenixCReal': 0.2,
          'phoenixCImag': 0.1,
          'phoenixP': -0.65,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.2,
          rotation: Vector3.zero(),
        ),
      ),
      // Feathered Wings - delicate wing-like patterns
      defaultPreset.copyWith(
        id: 'phoenix-wings',
        name: 'Feathered Wings',
        params: {
          'iterations': 300,
          'bailout': 4.5,
          'colorScheme': 4, // Phoenix
          'phoenixCReal': 0.56667,
          'phoenixCImag': 0.0,
          'phoenixP': -0.5,
        },
        view: FractalViewState(
          pan: Vector2(0.0, 0.1),
          zoom: 1.8,
          rotation: Vector3.zero(),
        ),
      ),
      // Ember Glow - warm glowing coals
      defaultPreset.copyWith(
        id: 'phoenix-ember',
        name: 'Ember Glow',
        params: {
          'iterations': 250,
          'bailout': 5.0,
          'colorScheme': 0, // Fire
          'phoenixCReal': 0.3,
          'phoenixCImag': 0.05,
          'phoenixP': -0.55,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
      ),
      // Solar Flare - explosive sun-like patterns
      defaultPreset.copyWith(
        id: 'phoenix-solar',
        name: 'Solar Flare',
        params: {
          'iterations': 350,
          'bailout': 4.0,
          'colorScheme': 0, // Fire
          'phoenixCReal': 0.35,
          'phoenixCImag': -0.15,
          'phoenixP': -0.7,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.5,
          rotation: Vector3.zero(),
        ),
      ),
      // Midnight Phoenix - dark mystical version
      defaultPreset.copyWith(
        id: 'phoenix-midnight',
        name: 'Midnight Phoenix',
        params: {
          'iterations': 280,
          'bailout': 4.0,
          'colorScheme': 1, // Ocean
          'phoenixCReal': 0.5,
          'phoenixCImag': 0.05,
          'phoenixP': -0.45,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.4,
          rotation: Vector3.zero(),
        ),
      ),
      // Cosmic Rebirth - psychedelic space phoenix
      defaultPreset.copyWith(
        id: 'phoenix-cosmic',
        name: 'Cosmic Rebirth',
        params: {
          'iterations': 320,
          'bailout': 5.5,
          'colorScheme': 2, // Psychedelic
          'phoenixCReal': 0.4,
          'phoenixCImag': -0.2,
          'phoenixP': -0.4,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Ash & Flame - grayscale with hint of structure
      defaultPreset.copyWith(
        id: 'phoenix-ash',
        name: 'Ash & Flame',
        params: {
          'iterations': 260,
          'bailout': 4.0,
          'colorScheme': 3, // Grayscale
          'phoenixCReal': 0.45,
          'phoenixCImag': 0.0,
          'phoenixP': -0.6,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.6,
          rotation: Vector3.zero(),
        ),
      ),
      // Firebird - detailed feather textures
      defaultPreset.copyWith(
        id: 'phoenix-firebird',
        name: 'Firebird',
        params: {
          'iterations': 380,
          'bailout': 4.5,
          'colorScheme': 4, // Phoenix
          'phoenixCReal': 0.52,
          'phoenixCImag': 0.08,
          'phoenixP': -0.52,
        },
        view: FractalViewState(
          pan: Vector2(0.0, -0.05),
          zoom: 2.2,
          rotation: Vector3.zero(),
        ),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final iterations = _readDouble(state.params, 'iterations', 180);
      final bailout = _readDouble(state.params, 'bailout', 4.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 4);
      final phoenixCReal = _readDouble(state.params, 'phoenixCReal', 0.5667);
      final phoenixCImag = _readDouble(state.params, 'phoenixCImag', 0.0);
      final phoenixP = _readDouble(state.params, 'phoenixP', -0.5);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations);
      shader.setFloat(7, bailout);
      shader.setFloat(8, colorScheme);
      shader.setFloat(9, phoenixCReal);
      shader.setFloat(10, phoenixCImag);
      shader.setFloat(11, phoenixP);
      shader.setFloat(12, state.transparentBackground ? 1.0 : 0.0);

      // GPU-safe: no custom palette uniform block in phoenix_gpu.frag
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

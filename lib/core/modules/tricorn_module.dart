import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildTricornModule() {
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
    FractalParameter(
      id: 'colorScheme',
      label: (l10n) => l10n.paramColorScheme,
      type: FractalParamType.enumeration,
      min: 0,
      max: 3,
      step: 1,
      defaultValue: 0,
      options: [
        FractalParamOption(value: 0, label: (l10n) => l10n.colorFire),
        FractalParamOption(value: 1, label: (l10n) => l10n.colorOcean),
        FractalParamOption(value: 2, label: (l10n) => l10n.colorPsychedelic),
        FractalParamOption(value: 3, label: (l10n) => l10n.colorGrayscale),
      ],
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'tricorn-default',
    moduleId: 'tricorn',
    name: 'Default',
    params: {
      'iterations': 180,
      'bailout': 4.0,
      'colorScheme': 0,
    },
    view: FractalViewState(
      pan: Vector2(-0.0, 0.0),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'tricorn',
    displayName: (l10n) => 'Tricorn',
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/tricorn_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset.copyWith(id: 'tricorn-classic', name: 'Classic')],
    setUniforms: (shader, state, size, time) {
      final iterations = _readDouble(state.params, 'iterations', 180);
      final bailout = _readDouble(state.params, 'bailout', 4.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 0);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations);
      shader.setFloat(7, bailout);
      shader.setFloat(8, colorScheme);
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}

double _readDouble(Map<String, Object> params, String key, double fallback) {
  final value = params[key];
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return fallback;
}

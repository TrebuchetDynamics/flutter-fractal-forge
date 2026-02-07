import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

FractalModule buildMandelbulbModule() {
  final parameters = [
    FractalParameter(
      id: 'power',
      label: (l10n) => l10n.paramPower,
      type: FractalParamType.float,
      min: 2.0,
      max: 12.0,
      step: 0.1,
      defaultValue: 8.0,
    ),
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 10,
      max: 100,
      step: 1,
      defaultValue: 50,
    ),
    FractalParameter(
      id: 'steps',
      label: (l10n) => l10n.paramSteps,
      type: FractalParamType.integer,
      min: 20,
      max: 200,
      step: 1,
      defaultValue: 120,
    ),
    FractalParameter(
      id: 'bailout',
      label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float,
      min: 1.0,
      max: 4.0,
      step: 0.1,
      defaultValue: 2.0,
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
    FractalParameter(
      id: 'fractalType',
      label: (l10n) => l10n.paramFractalType,
      type: FractalParamType.enumeration,
      min: 0,
      max: 3,
      step: 1,
      defaultValue: 0,
      options: [
        FractalParamOption(value: 0, label: (l10n) => l10n.fractalTypeMandelbulb),
        FractalParamOption(value: 1, label: (l10n) => l10n.fractalTypeMandelbox),
        FractalParamOption(value: 2, label: (l10n) => l10n.fractalTypeJulia),
        FractalParamOption(value: 3, label: (l10n) => l10n.fractalTypeSierpinski),
      ],
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'mandelbulb-default',
    moduleId: 'mandelbulb',
    name: 'Default',
    params: {
      'power': 8.0,
      'iterations': 50,
      'steps': 120,
      'bailout': 2.0,
      'colorScheme': 0,
      'fractalType': 0,
    },
    view: FractalViewState.initial(),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'mandelbulb',
    displayName: (l10n) => l10n.moduleMandelbulb,
    dimension: FractalDimension.threeD,
    shaderAsset: 'shaders/mandelbulb.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'mandelbulb-classic', name: 'Classic'),
      defaultPreset.copyWith(
        id: 'mandelbulb-deep',
        name: 'Deep Bloom',
        params: {
          'power': 7.0,
          'iterations': 70,
          'steps': 150,
          'bailout': 2.2,
          'colorScheme': 1,
          'fractalType': 0,
        },
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final power = _readDouble(state.params, 'power', 8.0);
      final iterations = _readDouble(state.params, 'iterations', 50);
      final steps = _readDouble(state.params, 'steps', 120);
      final bailout = _readDouble(state.params, 'bailout', 2.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 0);
      final fractalType = _readDouble(state.params, 'fractalType', 0);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, 0.0);
      shader.setFloat(4, 0.0);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, state.view.rotation.x);
      shader.setFloat(7, state.view.rotation.y);
      shader.setFloat(8, state.view.rotation.z);
      shader.setFloat(9, power);
      shader.setFloat(10, iterations);
      shader.setFloat(11, steps);
      shader.setFloat(12, bailout);
      shader.setFloat(13, colorScheme);
      shader.setFloat(14, fractalType);
      shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);
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

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
// import 'package:flutter_fractals/l10n/app_localizations.dart'; // unused

FractalModule buildJuliaModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: 500,
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
    shaderAsset: 'shaders/julia.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'julia-classic', name: 'Classic'),
      defaultPreset.copyWith(
        id: 'julia-electric',
        name: 'Electric',
        params: {
          'iterations': 220,
          'bailout': 4.0,
          'colorScheme': 2,
          'juliaCReal': -0.4,
          'juliaCImag': 0.6,
        },
      ),
      defaultPreset.copyWith(
        id: 'julia-deep',
        name: 'Deep Sea',
        params: {
          'iterations': 260,
          'bailout': 4.0,
          'colorScheme': 1,
          'juliaCReal': -0.75,
          'juliaCImag': -0.05,
        },
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

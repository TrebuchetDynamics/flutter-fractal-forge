import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildBuffaloModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations', label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer, min: 20, max: 500, step: 1, defaultValue: 180,
    ),
    FractalParameter(
      id: 'bailout', label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float, min: 2.0, max: 8.0, step: 0.1, defaultValue: 4.0,
    ),
    CommonFractalParams.colorScheme64(defaultValue: 0),
  ];

  final defaultPreset = FractalPreset(
    id: 'buffalo-default', moduleId: 'buffalo', name: 'Default',
    params: const {'iterations': 180, 'bailout': 4.0, 'colorScheme': 0},
    view: FractalViewState(pan: Vector2(0.0, 0.0), zoom: 1.0, rotation: Vector3.zero()),
    createdAt: DateTime.now(), isBuiltIn: true,
  );

  return FractalModule(
    id: 'buffalo',
    displayName: (l10n) => 'Buffalo',
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/buffalo_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset.copyWith(id: 'buffalo-classic', name: 'Classic')],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, _d(state.params, 'iterations', 180));
      shader.setFloat(7, _d(state.params, 'bailout', 4.0));
      shader.setFloat(8, _d(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}

double _d(Map<String, Object> p, String k, double f) {
  final v = p[k]; if (v is int) return v.toDouble(); if (v is double) return v; return f;
}

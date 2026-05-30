import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildNovaModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: 5000,
      step: 1,
      defaultValue: 200,
    ),
    FractalParameter(
      id: 'relaxation',
      label: (l10n) => 'Relaxation',
      type: FractalParamType.float,
      min: 0.1,
      max: 3.0,
      step: 0.05,
      defaultValue: 1.0,
    ),
    CommonFractalParams.colorScheme64(defaultValue: 0),
  ];

  final defaultPreset = FractalPreset(
    id: 'nova-default',
    moduleId: 'nova',
    name: 'Default',
    params: {'iterations': 200, 'relaxation': 1.0, 'colorScheme': 2},
    view: FractalViewState(
        pan: Vector2(0.0, 0.0), zoom: 1.5, rotation: Vector3.zero()),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'nova',
    displayName: (l10n) => 'Nova',
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/escape_time_family/families/nova/nova_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'nova-classic', name: 'Classic'),
      defaultPreset.copyWith(
        id: 'nova-roots',
        name: 'Three Roots',
        params: {'iterations': 300, 'relaxation': 1.0, 'colorScheme': 1},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 2.0, rotation: Vector3.zero()),
      ),
      defaultPreset.copyWith(
        id: 'nova-overrelaxed',
        name: 'Over-Relaxed',
        params: {'iterations': 250, 'relaxation': 1.5, 'colorScheme': 0},
        view: FractalViewState(
            pan: Vector2(0.0, 0.0), zoom: 1.5, rotation: Vector3.zero()),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, readDouble(state.params, 'iterations', 200));
      shader.setFloat(7, readDouble(state.params, 'relaxation', 1.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}



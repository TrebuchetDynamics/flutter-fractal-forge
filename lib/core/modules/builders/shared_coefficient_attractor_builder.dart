import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildSharedCoefficientAttractorModule({
  required String id,
  required String name,
  required String shaderAsset,
  required double a,
  required double b,
  required double c,
  required double d,
  required double bailout,
  required double coefficientMin,
  required double coefficientMax,
}) {
  final defaultPreset = catalogPreset(
    id: '${id}_default',
    moduleId: id,
    name: name,
    params: {
      'iterations': 220,
      'bailout': bailout,
      'colorScheme': 0,
      'a': a,
      'b': b,
      'c': c,
      'd': d,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 0.65,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: id,
    displayName: (_) => name,
    dimension: FractalDimension.twoD,
    shaderAsset: shaderAsset,
    parameters: [
      CommonFractalParams.iterations(defaultValue: 220, max: 500),
      CommonFractalParams.bailout(defaultValue: bailout),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      _coefficientParam('a', a, min: coefficientMin, max: coefficientMax),
      _coefficientParam('b', b, min: coefficientMin, max: coefficientMax),
      _coefficientParam('c', c, min: coefficientMin, max: coefficientMax),
      _coefficientParam('d', d, min: coefficientMin, max: coefficientMax),
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, readDouble(state.params, 'iterations', 220));
      shader.setFloat(7, readDouble(state.params, 'bailout', bailout));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(10, readDouble(state.params, 'a', a));
      shader.setFloat(11, readDouble(state.params, 'b', b));
      shader.setFloat(12, readDouble(state.params, 'c', c));
      shader.setFloat(13, readDouble(state.params, 'd', d));
    },
  );
}

FractalParameter _coefficientParam(
  String id,
  double defaultValue, {
  required double min,
  required double max,
}) =>
    FractalParameter(
      id: id,
      label: (_) => id,
      type: FractalParamType.float,
      min: min,
      max: max,
      step: 0.01,
      defaultValue: defaultValue,
    );

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
  double? coefficientRadius,
}) {
  final defaultPreset = catalogPreset(
    id: '${id}_default',
    moduleId: id,
    name: name,
    params: {
      'iterations': 360,
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
      CommonFractalParams.iterations(defaultValue: 360, min: 300, max: 500),
      CommonFractalParams.bailout(defaultValue: bailout, max: bailout),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      _coefficientParam('a', a,
          range: _coefficientRange(
              a, coefficientMin, coefficientMax, coefficientRadius)),
      _coefficientParam('b', b,
          range: _coefficientRange(
              b, coefficientMin, coefficientMax, coefficientRadius)),
      _coefficientParam('c', c,
          range: _coefficientRange(
              c, coefficientMin, coefficientMax, coefficientRadius)),
      _coefficientParam('d', d,
          range: _coefficientRange(
              d, coefficientMin, coefficientMax, coefficientRadius)),
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
      shader.setFloat(
          6, _safeIterations(readDouble(state.params, 'iterations', 360)));
      shader.setFloat(7, readDouble(state.params, 'bailout', bailout));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(
          10,
          _safeCoefficient(readDouble(state.params, 'a', a), a, coefficientMin,
              coefficientMax, coefficientRadius));
      shader.setFloat(
          11,
          _safeCoefficient(readDouble(state.params, 'b', b), b, coefficientMin,
              coefficientMax, coefficientRadius));
      shader.setFloat(
          12,
          _safeCoefficient(readDouble(state.params, 'c', c), c, coefficientMin,
              coefficientMax, coefficientRadius));
      shader.setFloat(
          13,
          _safeCoefficient(readDouble(state.params, 'd', d), d, coefficientMin,
              coefficientMax, coefficientRadius));
    },
  );
}

double _safeIterations(double value) => value.clamp(300.0, 500.0).toDouble();

({double min, double max}) _coefficientRange(
  double center,
  double min,
  double max,
  double? radius,
) {
  if (radius == null) return (min: min, max: max);
  return (min: center - radius, max: center + radius);
}

double _safeCoefficient(
  double value,
  double center,
  double min,
  double max,
  double? radius,
) {
  final range = _coefficientRange(center, min, max, radius);
  return value.clamp(range.min, range.max).toDouble();
}

FractalParameter _coefficientParam(
  String id,
  double defaultValue, {
  required ({double min, double max}) range,
}) =>
    FractalParameter(
      id: id,
      label: (_) => id,
      type: FractalParamType.float,
      min: range.min,
      max: range.max,
      step: 0.01,
      defaultValue: defaultValue,
    );

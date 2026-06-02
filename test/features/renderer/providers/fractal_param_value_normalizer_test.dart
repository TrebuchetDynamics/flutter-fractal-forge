import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_param_value_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

String _label(_) => 'Parameter';

FractalParameter _booleanParam({required bool defaultValue}) {
  return FractalParameter(
    id: 'enabled',
    label: _label,
    type: FractalParamType.boolean,
    min: 0,
    max: 1,
    step: 1,
    defaultValue: defaultValue,
  );
}

void main() {
  group('normalizeFractalParamValue', () {
    test('preserves real boolean parameter values', () {
      final schema = _booleanParam(defaultValue: true);

      expect(normalizeFractalParamValue(schema, true), isTrue);
      expect(normalizeFractalParamValue(schema, false), isFalse);
    });

    test('falls back to boolean schema default for non-boolean values', () {
      expect(
        normalizeFractalParamValue(_booleanParam(defaultValue: true), 'true'),
        isTrue,
      );
      expect(
        normalizeFractalParamValue(_booleanParam(defaultValue: false), 1),
        isFalse,
      );
    });
  });
}

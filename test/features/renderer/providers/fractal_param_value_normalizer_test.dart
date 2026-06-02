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

FractalParameter _numericParam({
  required FractalParamType type,
  required Object defaultValue,
  double min = 1,
  double max = 10,
}) {
  return FractalParameter(
    id: 'value',
    label: _label,
    type: type,
    min: min,
    max: max,
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

    test('falls back to numeric schema default for non-finite numbers', () {
      final floatSchema = _numericParam(
        type: FractalParamType.float,
        defaultValue: 4.0,
      );
      final intSchema = _numericParam(
        type: FractalParamType.integer,
        defaultValue: 4,
      );

      for (final candidate in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          normalizeFractalParamValue(floatSchema, candidate),
          4.0,
          reason: 'float candidate=$candidate',
        );
        expect(
          normalizeFractalParamValue(intSchema, candidate),
          4,
          reason: 'integer candidate=$candidate',
        );
      }
    });

    test('keeps rounded integer values inside fractional schema bounds', () {
      final schema = _numericParam(
        type: FractalParamType.integer,
        defaultValue: 4,
        min: 1.2,
        max: 10.8,
      );
      final bounds = FractalNumericParamBounds.fromSchema(schema);

      expect(bounds.containsInteger, isTrue);
      expect(normalizeFractalParamValue(schema, 1.2), 2);
      expect(normalizeFractalParamValue(schema, 10.8), 10);
    });
  });
}

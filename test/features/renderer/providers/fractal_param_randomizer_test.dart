import 'dart:math';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_param_randomizer.dart';
import 'package:flutter_test/flutter_test.dart';

String _label(_) => 'Parameter';

FractalParameter _numericParam({
  required FractalParamType type,
  required Object defaultValue,
  double min = 1.2,
  double max = 10.8,
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

final class _FixedRandom implements Random {
  _FixedRandom({
    required this.nextIntValue,
    this.nextDoubleValue = 0.0,
  });

  final int Function(int max) nextIntValue;
  final double nextDoubleValue;

  @override
  int nextInt(int max) => nextIntValue(max);

  @override
  double nextDouble() => nextDoubleValue;

  @override
  bool nextBool() => false;
}

void main() {
  group('randomFractalParamValue', () {
    test('keeps integer random values inside fractional schema bounds', () {
      final schema = _numericParam(
        type: FractalParamType.integer,
        defaultValue: 4,
      );

      expect(
        randomFractalParamValue(schema, _FixedRandom(nextIntValue: (_) => 0)),
        2,
      );
      expect(
        randomFractalParamValue(
          schema,
          _FixedRandom(nextIntValue: (max) => max - 1),
        ),
        10,
      );
    });

    test('normalizes stepped float random values back to schema bounds', () {
      final schema = _numericParam(
        type: FractalParamType.float,
        defaultValue: 4.0,
      );

      expect(
        randomFractalParamValue(schema, _FixedRandom(nextIntValue: (_) => 0)),
        1.2,
      );
      expect(
        randomFractalParamValue(
          schema,
          _FixedRandom(
            nextIntValue: (_) => 0,
            nextDoubleValue: 0.99,
          ),
        ),
        10.8,
      );
    });
  });
}

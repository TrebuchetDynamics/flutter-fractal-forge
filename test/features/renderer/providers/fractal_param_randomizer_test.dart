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
  group('FractalParamStepSnapPlan', () {
    test('exposes whether slider-step snapping was applied', () {
      final snapped = FractalParamStepSnapPlan.fromValue(
        value: 1.234567,
        step: 0.1,
      );
      final unsnapped = FractalParamStepSnapPlan.fromValue(
        value: 1.234567,
        step: double.nan,
      );

      expect(snapped.value, 1.2);
      expect(snapped.appliedStep, isTrue);
      expect(unsnapped.value, 1.234567);
      expect(unsnapped.appliedStep, isFalse);
    });
  });

  group('roundFractalParamValueToStep', () {
    test('ignores non-finite steps instead of throwing during randomization',
        () {
      expect(roundFractalParamValueToStep(1.234567, double.nan), 1.234567);
      expect(roundFractalParamValueToStep(1.234567, double.infinity), 1.234567);
    });

    test('keeps non-finite values replayable for later schema normalization',
        () {
      expect(roundFractalParamValueToStep(double.nan, 0.1), isNaN);
      expect(
          roundFractalParamValueToStep(double.infinity, 0.1), double.infinity);
    });
  });

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

    test('does not crash when a float schema has a non-finite step', () {
      final schema = FractalParameter(
        id: 'value',
        label: _label,
        type: FractalParamType.float,
        min: 1.2,
        max: 10.8,
        step: double.nan,
        defaultValue: 4.0,
      );

      expect(
        randomFractalParamValue(
          schema,
          _FixedRandom(
            nextIntValue: (_) => 0,
            nextDoubleValue: 0.5,
          ),
        ),
        closeTo(6.0, 1e-12),
      );
    });
  });
}

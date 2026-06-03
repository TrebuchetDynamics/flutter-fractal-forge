import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/controls/param_control_plan.dart';
import 'package:flutter_test/flutter_test.dart';

String _label(_) => 'Parameter';

FractalParameter _numericParam({
  required FractalParamType type,
  required Object defaultValue,
  double min = 1,
  double max = 10,
  double step = 1,
}) {
  return FractalParameter(
    id: 'value',
    label: _label,
    type: type,
    min: min,
    max: max,
    step: step,
    defaultValue: defaultValue,
  );
}

void main() {
  group('NumericParamControlPlan', () {
    test('uses the clamped slider value for integer labels and updates', () {
      final plan = NumericParamControlPlan.fromParam(
        param: _numericParam(
          type: FractalParamType.integer,
          defaultValue: 5,
          min: 1,
          max: 10,
        ),
        value: 99,
      );

      expect(plan.value, 10);
      expect(plan.valueLabel, '10');
      expect(plan.valueForSliderPosition(99), 10);
    });

    test('falls back to numeric defaults for non-finite values', () {
      final plan = NumericParamControlPlan.fromParam(
        param: _numericParam(
          type: FractalParamType.float,
          defaultValue: 4.25,
          min: 1,
          max: 10,
          step: 0.25,
        ),
        value: double.nan,
      );

      expect(plan.value, 4.25);
      expect(plan.valueLabel, '4.25');
    });

    test('uses schema step precision for fine-grained float labels and updates',
        () {
      final plan = NumericParamControlPlan.fromParam(
        param: _numericParam(
          type: FractalParamType.float,
          defaultValue: 0.0,
          min: -2,
          max: 2,
          step: 0.001,
        ),
        value: 1.234,
      );

      expect(plan.value, 1.234);
      expect(plan.valueLabel, '1.234');
      expect(plan.valueForSliderPosition(-1.234), -1.234);
    });

    test('does not derive slider divisions from malformed steps', () {
      for (final step in [0.0, -1.0, double.nan, double.infinity]) {
        final plan = NumericParamControlPlan.fromParam(
          param: _numericParam(
            type: FractalParamType.float,
            defaultValue: 5.0,
            step: step,
          ),
          value: 5.0,
        );

        expect(plan.divisions, isNull, reason: 'step=$step');
      }
    });

    test('integer emissions honor fractional numeric bounds', () {
      final plan = NumericParamControlPlan.fromParam(
        param: _numericParam(
          type: FractalParamType.integer,
          defaultValue: 4,
          min: 1.2,
          max: 10.8,
        ),
        value: 1.2,
      );

      expect(plan.valueLabel, '2');
      expect(plan.valueForSliderPosition(1.2), 2);
      expect(plan.valueForSliderPosition(10.8), 10);
    });
  });

  group('NumericParamControlRange', () {
    test('sanitizes reversed and non-finite schema bounds for replay', () {
      final reversed = NumericParamControlRange.fromParam(
        _numericParam(
          type: FractalParamType.float,
          defaultValue: 5.0,
          min: 10,
          max: 1,
        ),
      );
      final nonFinite = NumericParamControlRange.fromParam(
        _numericParam(
          type: FractalParamType.float,
          defaultValue: 5.0,
          min: double.nan,
          max: double.infinity,
        ),
      );

      expect(reversed.min, 1);
      expect(reversed.max, 10);
      expect(nonFinite.min, 0);
      expect(nonFinite.max, 0);
    });
  });
}

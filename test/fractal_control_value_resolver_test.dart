import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/controls/fractal_control_value_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FractalControlValueResolver', () {
    test('preserves schema precision for high-resolution float sliders', () {
      const parameter = FractalParameter(
        id: 'juliaCReal',
        label: _label,
        type: FractalParamType.float,
        min: -2,
        max: 2,
        step: 0.001,
        defaultValue: -0.7269,
      );

      final resolved = FractalControlValueResolver.resolveNumeric(
        parameter: parameter,
        rawValue: -0.7269,
      );

      expect(resolved.valueLabel, '-0.727');
      expect(resolved.divisions, 4000);
      expect(resolved.valueFromSlider(0.18894), 0.189);
    });

    test('falls back to a safe numeric default when the raw value is invalid',
        () {
      const parameter = FractalParameter(
        id: 'iterations',
        label: _label,
        type: FractalParamType.integer,
        min: 10,
        max: 500,
        step: 1,
        defaultValue: 180,
      );

      final resolved = FractalControlValueResolver.resolveNumeric(
        parameter: parameter,
        rawValue: 'bad',
      );

      expect(resolved.sliderValue, 180);
      expect(resolved.valueLabel, '180');
      expect(resolved.valueFromSlider(999), 500);
    });

    test('tolerates non-positive numeric steps by disabling slider divisions',
        () {
      const parameter = FractalParameter(
        id: 'unstable',
        label: _label,
        type: FractalParamType.float,
        min: 0,
        max: 1,
        step: 0,
        defaultValue: 0.25,
      );

      final resolved = FractalControlValueResolver.resolveNumeric(
        parameter: parameter,
        rawValue: 0.25,
      );

      expect(resolved.divisions, isNull);
      expect(resolved.valueFromSlider(0.333333), 0.333333);
    });

    test('normalizes invalid enum values to the declared default', () {
      const parameter = FractalParameter(
        id: 'palette',
        label: _label,
        type: FractalParamType.enumeration,
        min: 0,
        max: 2,
        step: 1,
        defaultValue: 1,
        options: [
          FractalParamOption(value: 0, label: _label),
          FractalParamOption(value: 1, label: _label),
          FractalParamOption(value: 2, label: _label),
        ],
      );

      final value = FractalControlValueResolver.normalizeEnumerationValue(
        parameter: parameter,
        rawValue: 999,
      );

      expect(value, 1);
      expect(
        FractalControlValueResolver.useScrollableOptions(parameter),
        isFalse,
      );
    });

    test('normalizes invalid booleans to the schema default', () {
      const parameter = FractalParameter(
        id: 'locked',
        label: _label,
        type: FractalParamType.boolean,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: true,
      );

      final value = FractalControlValueResolver.normalizeBooleanValue(
        parameter: parameter,
        rawValue: 'bad',
      );

      expect(value, isTrue);
    });
  });
}

String _label(_) => 'label';

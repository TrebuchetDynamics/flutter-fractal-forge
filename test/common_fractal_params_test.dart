import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';

void main() {
  group('CommonFractalParams', () {
    test(
        'builds standard escape-time iteration parameter without changing schema',
        () {
      final parameter = CommonFractalParams.iterations(defaultValue: 160);

      expect(parameter.id, 'iterations');
      expect(parameter.type, FractalParamType.integer);
      expect(parameter.min, 20);
      expect(parameter.max, 5000);
      expect(parameter.step, 1);
      expect(parameter.defaultValue, 160);
    });

    test(
        'builds standard escape-time bailout parameter without changing schema',
        () {
      final parameter = CommonFractalParams.bailout(defaultValue: 4.0);

      expect(parameter.id, 'bailout');
      expect(parameter.type, FractalParamType.float);
      expect(parameter.min, 2.0);
      expect(parameter.max, 8.0);
      expect(parameter.step, 0.1);
      expect(parameter.defaultValue, 4.0);
    });

    test(
        'builds four-palette 3D color scheme parameter without changing options',
        () {
      final parameter = CommonFractalParams.colorScheme4(defaultValue: 0);

      expect(parameter.id, 'colorScheme');
      expect(parameter.type, FractalParamType.enumeration);
      expect(parameter.min, 0);
      expect(parameter.max, 3);
      expect(parameter.step, 1);
      expect(parameter.defaultValue, 0);
      expect(parameter.options.map((option) => option.value), [0, 1, 2, 3]);
    });
  });
}

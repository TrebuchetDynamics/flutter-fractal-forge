import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonFractalParams.raySteps', () {
    test('preserves custom range and label', () {
      final parameter = CommonFractalParams.raySteps(
        defaultValue: 120,
        min: 32,
        max: 180,
        label: 'Volume Steps',
      );

      expect(parameter.id, 'steps');
      expect(parameter.type, FractalParamType.integer);
      expect(parameter.min, 32.0);
      expect(parameter.max, 180.0);
      expect(parameter.step, 1.0);
      expect(parameter.defaultValue, 120);
    });
  });

  group('CommonFractalParams.constantCoordinate', () {
    test('uses explicit label and coordinate bounds', () {
      final parameter = CommonFractalParams.constantCoordinate(
        id: 'cx',
        label: 'C X',
        defaultValue: -0.2,
        min: -0.95,
        max: 0.95,
      );

      expect(parameter.id, 'cx');
      expect(parameter.type, FractalParamType.float);
      expect(parameter.min, -0.95);
      expect(parameter.max, 0.95);
      expect(parameter.step, 0.01);
      expect(parameter.defaultValue, -0.2);
    });

    test('defaults to the unit interval for 3D constants', () {
      final parameter = CommonFractalParams.constantCoordinate(
        id: 'cz',
        label: 'C Z',
        defaultValue: 0.0,
      );

      expect(parameter.min, -1.0);
      expect(parameter.max, 1.0);
      expect(parameter.defaultValue, 0.0);
    });
  });
}

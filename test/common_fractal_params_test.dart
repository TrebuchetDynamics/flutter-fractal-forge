import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';

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

    test('builds color count parameter for palette sampler modules', () {
      final parameter = CommonFractalParams.colorCount();

      expect(parameter.id, 'colorCount');
      expect(parameter.type, FractalParamType.integer);
      expect(parameter.min, 2);
      expect(parameter.max, 64);
      expect(parameter.defaultValue, 64);
    });

    test('builds descriptive labels for all 64 color scheme options', () {
      final parameter = CommonFractalParams.colorScheme64(defaultValue: 0);
      final l10n = AppLocalizationsEn();

      expect(parameter.options, hasLength(64));
      expect(parameter.options[4].label(l10n), 'Phoenix');
      expect(parameter.options[5].label(l10n), 'Viridis Depth');
      expect(parameter.options[7].label(l10n), 'Cividis Safe');
      expect(parameter.options[49].label(l10n), 'Starlight Candy');
      expect(parameter.options[50].label(l10n), 'Relief 0° Fire');
      expect(parameter.options[63].label(l10n), 'Relief 180° Ocean');
      expect(
        parameter.options.map((option) => option.label(l10n)),
        isNot(contains(startsWith('Palette '))),
      );
    });
  });
}

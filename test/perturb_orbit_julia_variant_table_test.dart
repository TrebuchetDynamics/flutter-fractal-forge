import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('julia variant perturbation specs', () {
    test('core julia and verified family variants are present', () {
      expect(kJuliaVariantSpecs['julia']!.baseId, 'mandelbrot');
      expect(kJuliaVariantSpecs['celtic_julia']!.baseId, 'celtic');
      expect(kJuliaVariantSpecs['celtic_julia']!.cReal, -0.70176);
      expect(kJuliaVariantSpecs['celtic_julia']!.cImag, -0.3842);
      expect(kJuliaVariantSpecs['buffalo_julia']!.cReal, -0.45);
      expect(kJuliaVariantSpecs['burning_ship_julia']!.cReal, -0.52);
      expect(kJuliaVariantSpecs['tricorn_julia']!.cImag, 0.74);
    });

    test('f-series preset julias route as z^2+c with param-sourced c', () {
      for (final id in [
        'f0143_dendrite_julia',
        'f0146_basilica_julia',
        'f0158_period_7_julia',
        'f0176_dendritic_tree_julia',
      ]) {
        final spec = kJuliaVariantSpecs[id];
        expect(spec, isNotNull, reason: id);
        expect(spec!.baseId, 'mandelbrot', reason: id);
        expect(spec.cReal, isNull,
            reason: '$id must read c from juliaCReal/juliaCImag params');
      }
    });

    test('every spec baseId maps to a real shader formula', () {
      const knownBaseIds = {
        'mandelbrot',
        'burning_ship',
        'buffalo',
        'tricorn',
        'celtic',
        'multibrot3',
        'multibrot4',
        'multibrot5',
        'phoenix',
      };
      for (final spec in kJuliaVariantSpecs.values) {
        expect(knownBaseIds, contains(spec.baseId));
      }
    });

    test('excluded families are not present', () {
      for (final id in [
        'phoenix_julia',
        'celtic_cubic_julia',
        'burning_ship_perp_julia',
        'cosine_julia',
        'perpendicular_julia',
        'dual_quaternion_julia',
      ]) {
        expect(kJuliaVariantSpecs.containsKey(id), isFalse, reason: id);
      }
    });
  });
}
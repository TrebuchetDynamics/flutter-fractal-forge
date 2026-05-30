// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0766_takagi_landsberg_curve/f0766_takagi_landsberg_curve_module.dart';

void main() {
  test('F0766TakagiLandsbergCurve instantiates', () {
    final m = F0766TakagiLandsbergCurve();
    expect(m.id, 'f0766_takagi_landsberg_curve');
    expect(m.shader, 'shaders/f0766_takagi_landsberg_curve_gpu.frag');
  });

  test('F0766TakagiLandsbergCurve presets are well-formed', () {
    final m = F0766TakagiLandsbergCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0766TakagiLandsbergCurve metadata is consistent', () {
    final m = F0766TakagiLandsbergCurve();
    expect(m.metadata.id, m.id);
  });
}

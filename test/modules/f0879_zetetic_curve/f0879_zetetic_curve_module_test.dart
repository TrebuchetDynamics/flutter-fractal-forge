// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0879_zetetic_curve/f0879_zetetic_curve_module.dart';

void main() {
  test('F0879ZeteticCurve instantiates', () {
    final m = F0879ZeteticCurve();
    expect(m.id, 'f0879_zetetic_curve');
    expect(m.shader, 'shaders/f0879_zetetic_curve_gpu.frag');
  });

  test('F0879ZeteticCurve presets are well-formed', () {
    final m = F0879ZeteticCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0879ZeteticCurve metadata is consistent', () {
    final m = F0879ZeteticCurve();
    expect(m.metadata.id, m.id);
  });
}

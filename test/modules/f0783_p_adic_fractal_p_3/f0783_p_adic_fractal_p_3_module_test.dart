// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0783_p_adic_fractal_p_3/f0783_p_adic_fractal_p_3_module.dart';

void main() {
  test('F0783PAdicFractalP3 instantiates', () {
    final m = F0783PAdicFractalP3();
    expect(m.id, 'f0783_p_adic_fractal_p_3');
    expect(m.shader, 'shaders/f0783_p_adic_fractal_p_3_gpu.frag');
  });

  test('F0783PAdicFractalP3 presets are well-formed', () {
    final m = F0783PAdicFractalP3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0783PAdicFractalP3 metadata is consistent', () {
    final m = F0783PAdicFractalP3();
    expect(m.metadata.id, m.id);
  });
}

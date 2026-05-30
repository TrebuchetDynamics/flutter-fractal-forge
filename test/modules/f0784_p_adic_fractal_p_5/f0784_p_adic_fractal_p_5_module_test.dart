// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0784_p_adic_fractal_p_5/f0784_p_adic_fractal_p_5_module.dart';

void main() {
  test('F0784PAdicFractalP5 instantiates', () {
    final m = F0784PAdicFractalP5();
    expect(m.id, 'f0784_p_adic_fractal_p_5');
    expect(m.shader, 'shaders/f0784_p_adic_fractal_p_5_gpu.frag');
  });

  test('F0784PAdicFractalP5 presets are well-formed', () {
    final m = F0784PAdicFractalP5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0784PAdicFractalP5 metadata is consistent', () {
    final m = F0784PAdicFractalP5();
    expect(m.metadata.id, m.id);
  });
}

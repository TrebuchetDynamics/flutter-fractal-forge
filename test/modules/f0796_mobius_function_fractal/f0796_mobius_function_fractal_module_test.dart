// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0796_mobius_function_fractal/f0796_mobius_function_fractal_module.dart';

void main() {
  test('F0796MobiusFunctionFractal instantiates', () {
    final m = F0796MobiusFunctionFractal();
    expect(m.id, 'f0796_mobius_function_fractal');
    expect(m.shader, 'shaders/f0796_mobius_function_fractal_gpu.frag');
  });

  test('F0796MobiusFunctionFractal presets are well-formed', () {
    final m = F0796MobiusFunctionFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0796MobiusFunctionFractal metadata is consistent', () {
    final m = F0796MobiusFunctionFractal();
    expect(m.metadata.id, m.id);
  });
}

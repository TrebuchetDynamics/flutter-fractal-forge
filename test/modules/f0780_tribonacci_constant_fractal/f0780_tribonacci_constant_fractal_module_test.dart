// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0780_tribonacci_constant_fractal/f0780_tribonacci_constant_fractal_module.dart';

void main() {
  test('F0780TribonacciConstantFractal instantiates', () {
    final m = F0780TribonacciConstantFractal();
    expect(m.id, 'f0780_tribonacci_constant_fractal');
    expect(m.shader, 'shaders/f0780_tribonacci_constant_fractal_gpu.frag');
  });

  test('F0780TribonacciConstantFractal presets are well-formed', () {
    final m = F0780TribonacciConstantFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0780TribonacciConstantFractal metadata is consistent', () {
    final m = F0780TribonacciConstantFractal();
    expect(m.metadata.id, m.id);
  });
}

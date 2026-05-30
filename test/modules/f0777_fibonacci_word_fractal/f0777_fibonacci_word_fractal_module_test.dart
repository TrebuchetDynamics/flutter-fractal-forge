// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0777_fibonacci_word_fractal/f0777_fibonacci_word_fractal_module.dart';

void main() {
  test('F0777FibonacciWordFractal instantiates', () {
    final m = F0777FibonacciWordFractal();
    expect(m.id, 'f0777_fibonacci_word_fractal');
    expect(m.shader, 'shaders/f0777_fibonacci_word_fractal_gpu.frag');
  });

  test('F0777FibonacciWordFractal presets are well-formed', () {
    final m = F0777FibonacciWordFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0777FibonacciWordFractal metadata is consistent', () {
    final m = F0777FibonacciWordFractal();
    expect(m.metadata.id, m.id);
  });
}

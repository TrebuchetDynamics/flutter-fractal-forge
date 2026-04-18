// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0876_fibonacci_word_fractal/f0876_fibonacci_word_fractal_module.dart';

void main() {
  test('F0876FibonacciWordFractal instantiates', () {
    final m = F0876FibonacciWordFractal();
    expect(m.id, 'f0876_fibonacci_word_fractal');
    expect(m.shader, 'shaders/f0876_fibonacci_word_fractal_gpu.frag');
  });

  test('F0876FibonacciWordFractal presets are well-formed', () {
    final m = F0876FibonacciWordFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0876FibonacciWordFractal metadata is consistent', () {
    final m = F0876FibonacciWordFractal();
    expect(m.metadata.id, m.id);
  });
}

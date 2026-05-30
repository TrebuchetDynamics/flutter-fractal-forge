// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0713_fibonacci_1d_substitution/f0713_fibonacci_1d_substitution_module.dart';

void main() {
  test('F0713Fibonacci1dSubstitution instantiates', () {
    final m = F0713Fibonacci1dSubstitution();
    expect(m.id, 'f0713_fibonacci_1d_substitution');
    expect(m.shader, 'shaders/f0713_fibonacci_1d_substitution_gpu.frag');
  });

  test('F0713Fibonacci1dSubstitution presets are well-formed', () {
    final m = F0713Fibonacci1dSubstitution();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0713Fibonacci1dSubstitution metadata is consistent', () {
    final m = F0713Fibonacci1dSubstitution();
    expect(m.metadata.id, m.id);
  });
}

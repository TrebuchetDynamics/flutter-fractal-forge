// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0714_tribonacci_substitution/f0714_tribonacci_substitution_module.dart';

void main() {
  test('F0714TribonacciSubstitution instantiates', () {
    final m = F0714TribonacciSubstitution();
    expect(m.id, 'f0714_tribonacci_substitution');
    expect(m.shader, 'shaders/f0714_tribonacci_substitution_gpu.frag');
  });

  test('F0714TribonacciSubstitution presets are well-formed', () {
    final m = F0714TribonacciSubstitution();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0714TribonacciSubstitution metadata is consistent', () {
    final m = F0714TribonacciSubstitution();
    expect(m.metadata.id, m.id);
  });
}

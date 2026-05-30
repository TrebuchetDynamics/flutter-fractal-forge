// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0790_rauzy_fractal_substitution/f0790_rauzy_fractal_substitution_module.dart';

void main() {
  test('F0790RauzyFractalSubstitution instantiates', () {
    final m = F0790RauzyFractalSubstitution();
    expect(m.id, 'f0790_rauzy_fractal_substitution');
    expect(m.shader, 'shaders/f0790_rauzy_fractal_substitution_gpu.frag');
  });

  test('F0790RauzyFractalSubstitution presets are well-formed', () {
    final m = F0790RauzyFractalSubstitution();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0790RauzyFractalSubstitution metadata is consistent', () {
    final m = F0790RauzyFractalSubstitution();
    expect(m.metadata.id, m.id);
  });
}

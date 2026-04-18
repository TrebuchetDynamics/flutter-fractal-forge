// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0782_beta_expansion_fractal_sqrt2/f0782_beta_expansion_fractal_sqrt2_module.dart';

void main() {
  test('F0782BetaExpansionFractalSqrt2 instantiates', () {
    final m = F0782BetaExpansionFractalSqrt2();
    expect(m.id, 'f0782_beta_expansion_fractal_sqrt2');
    expect(m.shader, 'shaders/f0782_beta_expansion_fractal_sqrt2_gpu.frag');
  });

  test('F0782BetaExpansionFractalSqrt2 presets are well-formed', () {
    final m = F0782BetaExpansionFractalSqrt2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0782BetaExpansionFractalSqrt2 metadata is consistent', () {
    final m = F0782BetaExpansionFractalSqrt2();
    expect(m.metadata.id, m.id);
  });
}

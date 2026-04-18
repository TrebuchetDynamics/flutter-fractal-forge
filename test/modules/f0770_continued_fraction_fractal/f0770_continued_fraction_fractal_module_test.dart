// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0770_continued_fraction_fractal/f0770_continued_fraction_fractal_module.dart';

void main() {
  test('F0770ContinuedFractionFractal instantiates', () {
    final m = F0770ContinuedFractionFractal();
    expect(m.id, 'f0770_continued_fraction_fractal');
    expect(m.shader, 'shaders/f0770_continued_fraction_fractal_gpu.frag');
  });

  test('F0770ContinuedFractionFractal presets are well-formed', () {
    final m = F0770ContinuedFractionFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0770ContinuedFractionFractal metadata is consistent', () {
    final m = F0770ContinuedFractionFractal();
    expect(m.metadata.id, m.id);
  });
}

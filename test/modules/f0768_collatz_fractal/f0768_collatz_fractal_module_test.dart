// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0768_collatz_fractal/f0768_collatz_fractal_module.dart';

void main() {
  test('F0768CollatzFractal instantiates', () {
    final m = F0768CollatzFractal();
    expect(m.id, 'f0768_collatz_fractal');
    expect(m.shader, 'shaders/f0768_collatz_fractal_gpu.frag');
  });

  test('F0768CollatzFractal presets are well-formed', () {
    final m = F0768CollatzFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0768CollatzFractal metadata is consistent', () {
    final m = F0768CollatzFractal();
    expect(m.metadata.id, m.id);
  });
}

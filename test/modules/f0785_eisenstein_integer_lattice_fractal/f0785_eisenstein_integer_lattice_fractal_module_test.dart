// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0785_eisenstein_integer_lattice_fractal/f0785_eisenstein_integer_lattice_fractal_module.dart';

void main() {
  test('F0785EisensteinIntegerLatticeFractal instantiates', () {
    final m = F0785EisensteinIntegerLatticeFractal();
    expect(m.id, 'f0785_eisenstein_integer_lattice_fractal');
    expect(m.shader, 'shaders/f0785_eisenstein_integer_lattice_fractal_gpu.frag');
  });

  test('F0785EisensteinIntegerLatticeFractal presets are well-formed', () {
    final m = F0785EisensteinIntegerLatticeFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0785EisensteinIntegerLatticeFractal metadata is consistent', () {
    final m = F0785EisensteinIntegerLatticeFractal();
    expect(m.metadata.id, m.id);
  });
}

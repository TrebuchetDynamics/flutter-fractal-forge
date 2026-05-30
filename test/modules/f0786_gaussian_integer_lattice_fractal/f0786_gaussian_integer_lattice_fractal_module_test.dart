// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0786_gaussian_integer_lattice_fractal/f0786_gaussian_integer_lattice_fractal_module.dart';

void main() {
  test('F0786GaussianIntegerLatticeFractal instantiates', () {
    final m = F0786GaussianIntegerLatticeFractal();
    expect(m.id, 'f0786_gaussian_integer_lattice_fractal');
    expect(m.shader, 'shaders/f0786_gaussian_integer_lattice_fractal_gpu.frag');
  });

  test('F0786GaussianIntegerLatticeFractal presets are well-formed', () {
    final m = F0786GaussianIntegerLatticeFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0786GaussianIntegerLatticeFractal metadata is consistent', () {
    final m = F0786GaussianIntegerLatticeFractal();
    expect(m.metadata.id, m.id);
  });
}

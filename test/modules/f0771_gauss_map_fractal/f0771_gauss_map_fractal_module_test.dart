// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0771_gauss_map_fractal/f0771_gauss_map_fractal_module.dart';

void main() {
  test('F0771GaussMapFractal instantiates', () {
    final m = F0771GaussMapFractal();
    expect(m.id, 'f0771_gauss_map_fractal');
    expect(m.shader, 'shaders/f0771_gauss_map_fractal_gpu.frag');
  });

  test('F0771GaussMapFractal presets are well-formed', () {
    final m = F0771GaussMapFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0771GaussMapFractal metadata is consistent', () {
    final m = F0771GaussMapFractal();
    expect(m.metadata.id, m.id);
  });
}

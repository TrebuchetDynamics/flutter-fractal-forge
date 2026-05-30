// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0855_fractal_canopy_asymmetric/f0855_fractal_canopy_asymmetric_module.dart';

void main() {
  test('F0855FractalCanopyAsymmetric instantiates', () {
    final m = F0855FractalCanopyAsymmetric();
    expect(m.id, 'f0855_fractal_canopy_asymmetric');
    expect(m.shader, 'shaders/f0855_fractal_canopy_asymmetric_gpu.frag');
  });

  test('F0855FractalCanopyAsymmetric presets are well-formed', () {
    final m = F0855FractalCanopyAsymmetric();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0855FractalCanopyAsymmetric metadata is consistent', () {
    final m = F0855FractalCanopyAsymmetric();
    expect(m.metadata.id, m.id);
  });
}

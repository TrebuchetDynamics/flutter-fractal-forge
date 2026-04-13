// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0532_gamma_squared_fractal/f0532_gamma_squared_fractal_module.dart';

void main() {
  test('F0532GammaSquaredFractal instantiates', () {
    final m = F0532GammaSquaredFractal();
    expect(m.id, 'f0532_gamma_squared_fractal');
    expect(m.shader, 'shaders/f0532_gamma_squared_fractal_gpu.frag');
  });

  test('F0532GammaSquaredFractal presets are well-formed', () {
    final m = F0532GammaSquaredFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0532GammaSquaredFractal metadata is consistent', () {
    final m = F0532GammaSquaredFractal();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0533_digamma_fractal/f0533_digamma_fractal_module.dart';

void main() {
  test('F0533DigammaFractal instantiates', () {
    final m = F0533DigammaFractal();
    expect(m.id, 'f0533_digamma_fractal');
    expect(m.shader, 'shaders/f0533_digamma_fractal_gpu.frag');
  });

  test('F0533DigammaFractal presets are well-formed', () {
    final m = F0533DigammaFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0533DigammaFractal metadata is consistent', () {
    final m = F0533DigammaFractal();
    expect(m.metadata.id, m.id);
  });
}

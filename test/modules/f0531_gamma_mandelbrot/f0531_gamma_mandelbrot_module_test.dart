// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0531_gamma_mandelbrot/f0531_gamma_mandelbrot_module.dart';

void main() {
  test('F0531GammaMandelbrot instantiates', () {
    final m = F0531GammaMandelbrot();
    expect(m.id, 'f0531_gamma_mandelbrot');
    expect(m.shader, 'shaders/f0531_gamma_mandelbrot_gpu.frag');
  });

  test('F0531GammaMandelbrot presets are well-formed', () {
    final m = F0531GammaMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0531GammaMandelbrot metadata is consistent', () {
    final m = F0531GammaMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

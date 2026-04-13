// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0487_cosine_mandelbrot/f0487_cosine_mandelbrot_module.dart';

void main() {
  test('F0487CosineMandelbrot instantiates', () {
    final m = F0487CosineMandelbrot();
    expect(m.id, 'f0487_cosine_mandelbrot');
    expect(m.shader, 'shaders/f0487_cosine_mandelbrot_gpu.frag');
  });

  test('F0487CosineMandelbrot presets are well-formed', () {
    final m = F0487CosineMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0487CosineMandelbrot metadata is consistent', () {
    final m = F0487CosineMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

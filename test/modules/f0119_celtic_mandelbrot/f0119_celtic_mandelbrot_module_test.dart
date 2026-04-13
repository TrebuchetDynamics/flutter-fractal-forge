// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0119_celtic_mandelbrot/f0119_celtic_mandelbrot_module.dart';

void main() {
  test('F0119CelticMandelbrot instantiates', () {
    final m = F0119CelticMandelbrot();
    expect(m.id, 'f0119_celtic_mandelbrot');
    expect(m.shader, 'shaders/f0119_celtic_mandelbrot_gpu.frag');
  });

  test('F0119CelticMandelbrot presets are well-formed', () {
    final m = F0119CelticMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0119CelticMandelbrot metadata is consistent', () {
    final m = F0119CelticMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

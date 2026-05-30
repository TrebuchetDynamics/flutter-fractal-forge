// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0486_sine_mandelbrot/f0486_sine_mandelbrot_module.dart';

void main() {
  test('F0486SineMandelbrot instantiates', () {
    final m = F0486SineMandelbrot();
    expect(m.id, 'f0486_sine_mandelbrot');
    expect(m.shader, 'shaders/f0486_sine_mandelbrot_gpu.frag');
  });

  test('F0486SineMandelbrot presets are well-formed', () {
    final m = F0486SineMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0486SineMandelbrot metadata is consistent', () {
    final m = F0486SineMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

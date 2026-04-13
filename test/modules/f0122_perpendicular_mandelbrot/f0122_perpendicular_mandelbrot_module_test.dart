// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0122_perpendicular_mandelbrot/f0122_perpendicular_mandelbrot_module.dart';

void main() {
  test('F0122PerpendicularMandelbrot instantiates', () {
    final m = F0122PerpendicularMandelbrot();
    expect(m.id, 'f0122_perpendicular_mandelbrot');
    expect(m.shader, 'shaders/f0122_perpendicular_mandelbrot_gpu.frag');
  });

  test('F0122PerpendicularMandelbrot presets are well-formed', () {
    final m = F0122PerpendicularMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0122PerpendicularMandelbrot metadata is consistent', () {
    final m = F0122PerpendicularMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

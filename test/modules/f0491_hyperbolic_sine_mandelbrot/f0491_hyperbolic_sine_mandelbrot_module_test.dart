// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0491_hyperbolic_sine_mandelbrot/f0491_hyperbolic_sine_mandelbrot_module.dart';

void main() {
  test('F0491HyperbolicSineMandelbrot instantiates', () {
    final m = F0491HyperbolicSineMandelbrot();
    expect(m.id, 'f0491_hyperbolic_sine_mandelbrot');
    expect(m.shader, 'shaders/f0491_hyperbolic_sine_mandelbrot_gpu.frag');
  });

  test('F0491HyperbolicSineMandelbrot presets are well-formed', () {
    final m = F0491HyperbolicSineMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0491HyperbolicSineMandelbrot metadata is consistent', () {
    final m = F0491HyperbolicSineMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

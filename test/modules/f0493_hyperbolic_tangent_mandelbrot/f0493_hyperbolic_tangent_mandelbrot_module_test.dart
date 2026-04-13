// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0493_hyperbolic_tangent_mandelbrot/f0493_hyperbolic_tangent_mandelbrot_module.dart';

void main() {
  test('F0493HyperbolicTangentMandelbrot instantiates', () {
    final m = F0493HyperbolicTangentMandelbrot();
    expect(m.id, 'f0493_hyperbolic_tangent_mandelbrot');
    expect(m.shader, 'shaders/f0493_hyperbolic_tangent_mandelbrot_gpu.frag');
  });

  test('F0493HyperbolicTangentMandelbrot presets are well-formed', () {
    final m = F0493HyperbolicTangentMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0493HyperbolicTangentMandelbrot metadata is consistent', () {
    final m = F0493HyperbolicTangentMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

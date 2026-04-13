// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0492_hyperbolic_cosine_mandelbrot/f0492_hyperbolic_cosine_mandelbrot_module.dart';

void main() {
  test('F0492HyperbolicCosineMandelbrot instantiates', () {
    final m = F0492HyperbolicCosineMandelbrot();
    expect(m.id, 'f0492_hyperbolic_cosine_mandelbrot');
    expect(m.shader, 'shaders/f0492_hyperbolic_cosine_mandelbrot_gpu.frag');
  });

  test('F0492HyperbolicCosineMandelbrot presets are well-formed', () {
    final m = F0492HyperbolicCosineMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0492HyperbolicCosineMandelbrot metadata is consistent', () {
    final m = F0492HyperbolicCosineMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

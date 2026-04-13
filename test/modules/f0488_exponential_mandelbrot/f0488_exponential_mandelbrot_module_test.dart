// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0488_exponential_mandelbrot/f0488_exponential_mandelbrot_module.dart';

void main() {
  test('F0488ExponentialMandelbrot instantiates', () {
    final m = F0488ExponentialMandelbrot();
    expect(m.id, 'f0488_exponential_mandelbrot');
    expect(m.shader, 'shaders/f0488_exponential_mandelbrot_gpu.frag');
  });

  test('F0488ExponentialMandelbrot presets are well-formed', () {
    final m = F0488ExponentialMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0488ExponentialMandelbrot metadata is consistent', () {
    final m = F0488ExponentialMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

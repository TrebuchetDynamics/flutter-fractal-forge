// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0126_mandelbrot_scaled/f0126_mandelbrot_scaled_module.dart';

void main() {
  test('F0126MandelbrotScaled instantiates', () {
    final m = F0126MandelbrotScaled();
    expect(m.id, 'f0126_mandelbrot_scaled');
    expect(m.shader, 'shaders/f0126_mandelbrot_scaled_gpu.frag');
  });

  test('F0126MandelbrotScaled presets are well-formed', () {
    final m = F0126MandelbrotScaled();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0126MandelbrotScaled metadata is consistent', () {
    final m = F0126MandelbrotScaled();
    expect(m.metadata.id, m.id);
  });
}

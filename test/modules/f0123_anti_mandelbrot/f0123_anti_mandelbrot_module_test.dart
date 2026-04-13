// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0123_anti_mandelbrot/f0123_anti_mandelbrot_module.dart';

void main() {
  test('F0123AntiMandelbrot instantiates', () {
    final m = F0123AntiMandelbrot();
    expect(m.id, 'f0123_anti_mandelbrot');
    expect(m.shader, 'shaders/f0123_anti_mandelbrot_gpu.frag');
  });

  test('F0123AntiMandelbrot presets are well-formed', () {
    final m = F0123AntiMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0123AntiMandelbrot metadata is consistent', () {
    final m = F0123AntiMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

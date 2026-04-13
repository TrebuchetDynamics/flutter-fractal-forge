// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0121_heart_mandelbrot/f0121_heart_mandelbrot_module.dart';

void main() {
  test('F0121HeartMandelbrot instantiates', () {
    final m = F0121HeartMandelbrot();
    expect(m.id, 'f0121_heart_mandelbrot');
    expect(m.shader, 'shaders/f0121_heart_mandelbrot_gpu.frag');
  });

  test('F0121HeartMandelbrot presets are well-formed', () {
    final m = F0121HeartMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0121HeartMandelbrot metadata is consistent', () {
    final m = F0121HeartMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

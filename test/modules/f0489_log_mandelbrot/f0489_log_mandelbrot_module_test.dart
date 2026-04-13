// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0489_log_mandelbrot/f0489_log_mandelbrot_module.dart';

void main() {
  test('F0489LogMandelbrot instantiates', () {
    final m = F0489LogMandelbrot();
    expect(m.id, 'f0489_log_mandelbrot');
    expect(m.shader, 'shaders/f0489_log_mandelbrot_gpu.frag');
  });

  test('F0489LogMandelbrot presets are well-formed', () {
    final m = F0489LogMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0489LogMandelbrot metadata is consistent', () {
    final m = F0489LogMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0120_buffalo_mandelbrot/f0120_buffalo_mandelbrot_module.dart';

void main() {
  test('F0120BuffaloMandelbrot instantiates', () {
    final m = F0120BuffaloMandelbrot();
    expect(m.id, 'f0120_buffalo_mandelbrot');
    expect(m.shader, 'shaders/f0120_buffalo_mandelbrot_gpu.frag');
  });

  test('F0120BuffaloMandelbrot presets are well-formed', () {
    final m = F0120BuffaloMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0120BuffaloMandelbrot metadata is consistent', () {
    final m = F0120BuffaloMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0490_tangent_mandelbrot/f0490_tangent_mandelbrot_module.dart';

void main() {
  test('F0490TangentMandelbrot instantiates', () {
    final m = F0490TangentMandelbrot();
    expect(m.id, 'f0490_tangent_mandelbrot');
    expect(m.shader, 'shaders/f0490_tangent_mandelbrot_gpu.frag');
  });

  test('F0490TangentMandelbrot presets are well-formed', () {
    final m = F0490TangentMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0490TangentMandelbrot metadata is consistent', () {
    final m = F0490TangentMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

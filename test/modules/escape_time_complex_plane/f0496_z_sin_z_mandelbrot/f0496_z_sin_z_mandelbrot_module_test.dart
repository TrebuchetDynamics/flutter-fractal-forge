// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0496_z_sin_z_mandelbrot/f0496_z_sin_z_mandelbrot_module.dart';

void main() {
  test('F0496ZSinZMandelbrot instantiates', () {
    final m = F0496ZSinZMandelbrot();
    expect(m.id, 'f0496_z_sin_z_mandelbrot');
    expect(m.shader, 'shaders/f0496_z_sin_z_mandelbrot_gpu.frag');
  });

  test('F0496ZSinZMandelbrot presets are well-formed', () {
    final m = F0496ZSinZMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0496ZSinZMandelbrot metadata is consistent', () {
    final m = F0496ZSinZMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0495_z_sin_z_mandelbrot/f0495_z_sin_z_mandelbrot_module.dart';

void main() {
  test('F0495ZSinZMandelbrot instantiates', () {
    final m = F0495ZSinZMandelbrot();
    expect(m.id, 'f0495_z_sin_z_mandelbrot');
    expect(m.shader, 'shaders/f0495_z_sin_z_mandelbrot_gpu.frag');
  });

  test('F0495ZSinZMandelbrot presets are well-formed', () {
    final m = F0495ZSinZMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0495ZSinZMandelbrot metadata is consistent', () {
    final m = F0495ZSinZMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

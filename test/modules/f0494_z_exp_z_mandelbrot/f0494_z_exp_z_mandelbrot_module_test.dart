// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0494_z_exp_z_mandelbrot/f0494_z_exp_z_mandelbrot_module.dart';

void main() {
  test('F0494ZExpZMandelbrot instantiates', () {
    final m = F0494ZExpZMandelbrot();
    expect(m.id, 'f0494_z_exp_z_mandelbrot');
    expect(m.shader, 'shaders/f0494_z_exp_z_mandelbrot_gpu.frag');
  });

  test('F0494ZExpZMandelbrot presets are well-formed', () {
    final m = F0494ZExpZMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0494ZExpZMandelbrot metadata is consistent', () {
    final m = F0494ZExpZMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

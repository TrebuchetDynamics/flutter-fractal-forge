// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0497_z_cos_z_mandelbrot/f0497_z_cos_z_mandelbrot_module.dart';

void main() {
  test('F0497ZCosZMandelbrot instantiates', () {
    final m = F0497ZCosZMandelbrot();
    expect(m.id, 'f0497_z_cos_z_mandelbrot');
    expect(m.shader, 'shaders/f0497_z_cos_z_mandelbrot_gpu.frag');
  });

  test('F0497ZCosZMandelbrot presets are well-formed', () {
    final m = F0497ZCosZMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0497ZCosZMandelbrot metadata is consistent', () {
    final m = F0497ZCosZMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

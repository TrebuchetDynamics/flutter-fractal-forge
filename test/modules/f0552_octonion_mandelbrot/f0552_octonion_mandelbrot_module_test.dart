// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0552_octonion_mandelbrot/f0552_octonion_mandelbrot_module.dart';

void main() {
  test('F0552OctonionMandelbrot instantiates', () {
    final m = F0552OctonionMandelbrot();
    expect(m.id, 'f0552_octonion_mandelbrot');
    expect(m.shader, 'shaders/f0552_octonion_mandelbrot_gpu.frag');
  });

  test('F0552OctonionMandelbrot presets are well-formed', () {
    final m = F0552OctonionMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0552OctonionMandelbrot metadata is consistent', () {
    final m = F0552OctonionMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

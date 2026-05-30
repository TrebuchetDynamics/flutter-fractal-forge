// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0551_bicomplex_mandelbrot/f0551_bicomplex_mandelbrot_module.dart';

void main() {
  test('F0551BicomplexMandelbrot instantiates', () {
    final m = F0551BicomplexMandelbrot();
    expect(m.id, 'f0551_bicomplex_mandelbrot');
    expect(m.shader, 'shaders/f0551_bicomplex_mandelbrot_gpu.frag');
  });

  test('F0551BicomplexMandelbrot presets are well-formed', () {
    final m = F0551BicomplexMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0551BicomplexMandelbrot metadata is consistent', () {
    final m = F0551BicomplexMandelbrot();
    expect(m.metadata.id, m.id);
  });
}

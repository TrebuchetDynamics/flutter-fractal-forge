// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0813_quadratic_map_mandelbrot_1d/f0813_quadratic_map_mandelbrot_1d_module.dart';

void main() {
  test('F0813QuadraticMapMandelbrot1d instantiates', () {
    final m = F0813QuadraticMapMandelbrot1d();
    expect(m.id, 'f0813_quadratic_map_mandelbrot_1d');
    expect(m.shader, 'shaders/f0813_quadratic_map_mandelbrot_1d_gpu.frag');
  });

  test('F0813QuadraticMapMandelbrot1d presets are well-formed', () {
    final m = F0813QuadraticMapMandelbrot1d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0813QuadraticMapMandelbrot1d metadata is consistent', () {
    final m = F0813QuadraticMapMandelbrot1d();
    expect(m.metadata.id, m.id);
  });
}

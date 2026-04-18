// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0764_weierstrass_mandelbrot_cosine/f0764_weierstrass_mandelbrot_cosine_module.dart';

void main() {
  test('F0764WeierstrassMandelbrotCosine instantiates', () {
    final m = F0764WeierstrassMandelbrotCosine();
    expect(m.id, 'f0764_weierstrass_mandelbrot_cosine');
    expect(m.shader, 'shaders/f0764_weierstrass_mandelbrot_cosine_gpu.frag');
  });

  test('F0764WeierstrassMandelbrotCosine presets are well-formed', () {
    final m = F0764WeierstrassMandelbrotCosine();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0764WeierstrassMandelbrotCosine metadata is consistent', () {
    final m = F0764WeierstrassMandelbrotCosine();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0563_mandelbulb_n_10/f0563_mandelbulb_n_10_module.dart';

void main() {
  test('F0563MandelbulbN10 instantiates', () {
    final m = F0563MandelbulbN10();
    expect(m.id, 'f0563_mandelbulb_n_10');
    expect(m.shader, 'shaders/f0563_mandelbulb_n_10_gpu.frag');
  });

  test('F0563MandelbulbN10 presets are well-formed', () {
    final m = F0563MandelbulbN10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0563MandelbulbN10 metadata is consistent', () {
    final m = F0563MandelbulbN10();
    expect(m.metadata.id, m.id);
  });
}

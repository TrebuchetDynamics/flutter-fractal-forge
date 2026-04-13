// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0560_mandelbulb_n_7/f0560_mandelbulb_n_7_module.dart';

void main() {
  test('F0560MandelbulbN7 instantiates', () {
    final m = F0560MandelbulbN7();
    expect(m.id, 'f0560_mandelbulb_n_7');
    expect(m.shader, 'shaders/f0560_mandelbulb_n_7_gpu.frag');
  });

  test('F0560MandelbulbN7 presets are well-formed', () {
    final m = F0560MandelbulbN7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0560MandelbulbN7 metadata is consistent', () {
    final m = F0560MandelbulbN7();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0559_mandelbulb_n_6/f0559_mandelbulb_n_6_module.dart';

void main() {
  test('F0559MandelbulbN6 instantiates', () {
    final m = F0559MandelbulbN6();
    expect(m.id, 'f0559_mandelbulb_n_6');
    expect(m.shader, 'shaders/f0559_mandelbulb_n_6_gpu.frag');
  });

  test('F0559MandelbulbN6 presets are well-formed', () {
    final m = F0559MandelbulbN6();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0559MandelbulbN6 metadata is consistent', () {
    final m = F0559MandelbulbN6();
    expect(m.metadata.id, m.id);
  });
}

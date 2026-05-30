// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0556_mandelbulb_n_3/f0556_mandelbulb_n_3_module.dart';

void main() {
  test('F0556MandelbulbN3 instantiates', () {
    final m = F0556MandelbulbN3();
    expect(m.id, 'f0556_mandelbulb_n_3');
    expect(m.shader, 'shaders/f0556_mandelbulb_n_3_gpu.frag');
  });

  test('F0556MandelbulbN3 presets are well-formed', () {
    final m = F0556MandelbulbN3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0556MandelbulbN3 metadata is consistent', () {
    final m = F0556MandelbulbN3();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0555_mandelbulb_n_2/f0555_mandelbulb_n_2_module.dart';

void main() {
  test('F0555MandelbulbN2 instantiates', () {
    final m = F0555MandelbulbN2();
    expect(m.id, 'f0555_mandelbulb_n_2');
    expect(m.shader, 'shaders/f0555_mandelbulb_n_2_gpu.frag');
  });

  test('F0555MandelbulbN2 presets are well-formed', () {
    final m = F0555MandelbulbN2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0555MandelbulbN2 metadata is consistent', () {
    final m = F0555MandelbulbN2();
    expect(m.metadata.id, m.id);
  });
}

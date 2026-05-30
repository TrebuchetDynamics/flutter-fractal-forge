// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0557_mandelbulb_n_4/f0557_mandelbulb_n_4_module.dart';

void main() {
  test('F0557MandelbulbN4 instantiates', () {
    final m = F0557MandelbulbN4();
    expect(m.id, 'f0557_mandelbulb_n_4');
    expect(m.shader, 'shaders/f0557_mandelbulb_n_4_gpu.frag');
  });

  test('F0557MandelbulbN4 presets are well-formed', () {
    final m = F0557MandelbulbN4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0557MandelbulbN4 metadata is consistent', () {
    final m = F0557MandelbulbN4();
    expect(m.metadata.id, m.id);
  });
}

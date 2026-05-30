// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0558_mandelbulb_n_5/f0558_mandelbulb_n_5_module.dart';

void main() {
  test('F0558MandelbulbN5 instantiates', () {
    final m = F0558MandelbulbN5();
    expect(m.id, 'f0558_mandelbulb_n_5');
    expect(m.shader, 'shaders/f0558_mandelbulb_n_5_gpu.frag');
  });

  test('F0558MandelbulbN5 presets are well-formed', () {
    final m = F0558MandelbulbN5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0558MandelbulbN5 metadata is consistent', () {
    final m = F0558MandelbulbN5();
    expect(m.metadata.id, m.id);
  });
}

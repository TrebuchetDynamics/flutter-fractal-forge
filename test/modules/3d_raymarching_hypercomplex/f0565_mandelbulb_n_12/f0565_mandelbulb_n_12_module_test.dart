// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0565_mandelbulb_n_12/f0565_mandelbulb_n_12_module.dart';

void main() {
  test('F0565MandelbulbN12 instantiates', () {
    final m = F0565MandelbulbN12();
    expect(m.id, 'f0565_mandelbulb_n_12');
    expect(m.shader, 'shaders/f0565_mandelbulb_n_12_gpu.frag');
  });

  test('F0565MandelbulbN12 presets are well-formed', () {
    final m = F0565MandelbulbN12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0565MandelbulbN12 metadata is consistent', () {
    final m = F0565MandelbulbN12();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0568_mandelbulb_n_20/f0568_mandelbulb_n_20_module.dart';

void main() {
  test('F0568MandelbulbN20 instantiates', () {
    final m = F0568MandelbulbN20();
    expect(m.id, 'f0568_mandelbulb_n_20');
    expect(m.shader, 'shaders/f0568_mandelbulb_n_20_gpu.frag');
  });

  test('F0568MandelbulbN20 presets are well-formed', () {
    final m = F0568MandelbulbN20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0568MandelbulbN20 metadata is consistent', () {
    final m = F0568MandelbulbN20();
    expect(m.metadata.id, m.id);
  });
}

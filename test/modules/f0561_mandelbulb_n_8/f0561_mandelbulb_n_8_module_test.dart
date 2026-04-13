// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0561_mandelbulb_n_8/f0561_mandelbulb_n_8_module.dart';

void main() {
  test('F0561MandelbulbN8 instantiates', () {
    final m = F0561MandelbulbN8();
    expect(m.id, 'f0561_mandelbulb_n_8');
    expect(m.shader, 'shaders/f0561_mandelbulb_n_8_gpu.frag');
  });

  test('F0561MandelbulbN8 presets are well-formed', () {
    final m = F0561MandelbulbN8();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0561MandelbulbN8 metadata is consistent', () {
    final m = F0561MandelbulbN8();
    expect(m.metadata.id, m.id);
  });
}

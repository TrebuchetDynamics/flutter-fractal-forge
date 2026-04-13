// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0569_mandelbulb_n_24/f0569_mandelbulb_n_24_module.dart';

void main() {
  test('F0569MandelbulbN24 instantiates', () {
    final m = F0569MandelbulbN24();
    expect(m.id, 'f0569_mandelbulb_n_24');
    expect(m.shader, 'shaders/f0569_mandelbulb_n_24_gpu.frag');
  });

  test('F0569MandelbulbN24 presets are well-formed', () {
    final m = F0569MandelbulbN24();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0569MandelbulbN24 metadata is consistent', () {
    final m = F0569MandelbulbN24();
    expect(m.metadata.id, m.id);
  });
}

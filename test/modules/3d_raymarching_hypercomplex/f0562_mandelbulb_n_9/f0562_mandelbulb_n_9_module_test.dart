// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0562_mandelbulb_n_9/f0562_mandelbulb_n_9_module.dart';

void main() {
  test('F0562MandelbulbN9 instantiates', () {
    final m = F0562MandelbulbN9();
    expect(m.id, 'f0562_mandelbulb_n_9');
    expect(m.shader, 'shaders/f0562_mandelbulb_n_9_gpu.frag');
  });

  test('F0562MandelbulbN9 presets are well-formed', () {
    final m = F0562MandelbulbN9();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0562MandelbulbN9 metadata is consistent', () {
    final m = F0562MandelbulbN9();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0566_mandelbulb_n_14/f0566_mandelbulb_n_14_module.dart';

void main() {
  test('F0566MandelbulbN14 instantiates', () {
    final m = F0566MandelbulbN14();
    expect(m.id, 'f0566_mandelbulb_n_14');
    expect(m.shader, 'shaders/f0566_mandelbulb_n_14_gpu.frag');
  });

  test('F0566MandelbulbN14 presets are well-formed', () {
    final m = F0566MandelbulbN14();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0566MandelbulbN14 metadata is consistent', () {
    final m = F0566MandelbulbN14();
    expect(m.metadata.id, m.id);
  });
}

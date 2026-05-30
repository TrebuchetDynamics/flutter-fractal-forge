// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0296_fractal_flame_swirl/f0296_fractal_flame_swirl_module.dart';

void main() {
  test('F0296FractalFlameSwirl instantiates', () {
    final m = F0296FractalFlameSwirl();
    expect(m.id, 'f0296_fractal_flame_swirl');
    expect(m.shader, 'shaders/f0296_fractal_flame_swirl_gpu.frag');
  });

  test('F0296FractalFlameSwirl presets are well-formed', () {
    final m = F0296FractalFlameSwirl();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0296FractalFlameSwirl metadata is consistent', () {
    final m = F0296FractalFlameSwirl();
    expect(m.metadata.id, m.id);
  });
}

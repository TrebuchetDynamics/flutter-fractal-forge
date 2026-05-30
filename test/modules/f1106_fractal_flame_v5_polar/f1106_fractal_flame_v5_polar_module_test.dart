// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1106_fractal_flame_v5_polar/f1106_fractal_flame_v5_polar_module.dart';

void main() {
  test('F1106FractalFlameV5Polar instantiates', () {
    final m = F1106FractalFlameV5Polar();
    expect(m.id, 'f1106_fractal_flame_v5_polar');
    expect(m.shader, 'shaders/f1106_fractal_flame_v5_polar_gpu.frag');
  });

  test('F1106FractalFlameV5Polar presets are well-formed', () {
    final m = F1106FractalFlameV5Polar();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1106FractalFlameV5Polar metadata is consistent', () {
    final m = F1106FractalFlameV5Polar();
    expect(m.metadata.id, m.id);
  });
}

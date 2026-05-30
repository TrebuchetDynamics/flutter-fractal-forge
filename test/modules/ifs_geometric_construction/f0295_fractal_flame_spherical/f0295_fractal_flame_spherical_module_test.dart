// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0295_fractal_flame_spherical/f0295_fractal_flame_spherical_module.dart';

void main() {
  test('F0295FractalFlameSpherical instantiates', () {
    final m = F0295FractalFlameSpherical();
    expect(m.id, 'f0295_fractal_flame_spherical');
    expect(m.shader, 'shaders/f0295_fractal_flame_spherical_gpu.frag');
  });

  test('F0295FractalFlameSpherical presets are well-formed', () {
    final m = F0295FractalFlameSpherical();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0295FractalFlameSpherical metadata is consistent', () {
    final m = F0295FractalFlameSpherical();
    expect(m.metadata.id, m.id);
  });
}

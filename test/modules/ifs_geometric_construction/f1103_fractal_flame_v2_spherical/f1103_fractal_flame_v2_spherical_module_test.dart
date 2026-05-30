// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1103_fractal_flame_v2_spherical/f1103_fractal_flame_v2_spherical_module.dart';

void main() {
  test('F1103FractalFlameV2Spherical instantiates', () {
    final m = F1103FractalFlameV2Spherical();
    expect(m.id, 'f1103_fractal_flame_v2_spherical');
    expect(m.shader, 'shaders/f1103_fractal_flame_v2_spherical_gpu.frag');
  });

  test('F1103FractalFlameV2Spherical presets are well-formed', () {
    final m = F1103FractalFlameV2Spherical();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1103FractalFlameV2Spherical metadata is consistent', () {
    final m = F1103FractalFlameV2Spherical();
    expect(m.metadata.id, m.id);
  });
}

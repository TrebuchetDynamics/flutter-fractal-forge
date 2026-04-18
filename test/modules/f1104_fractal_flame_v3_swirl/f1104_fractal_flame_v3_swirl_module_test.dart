// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1104_fractal_flame_v3_swirl/f1104_fractal_flame_v3_swirl_module.dart';

void main() {
  test('F1104FractalFlameV3Swirl instantiates', () {
    final m = F1104FractalFlameV3Swirl();
    expect(m.id, 'f1104_fractal_flame_v3_swirl');
    expect(m.shader, 'shaders/f1104_fractal_flame_v3_swirl_gpu.frag');
  });

  test('F1104FractalFlameV3Swirl presets are well-formed', () {
    final m = F1104FractalFlameV3Swirl();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1104FractalFlameV3Swirl metadata is consistent', () {
    final m = F1104FractalFlameV3Swirl();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1115_fractal_flame_v14_bent/f1115_fractal_flame_v14_bent_module.dart';

void main() {
  test('F1115FractalFlameV14Bent instantiates', () {
    final m = F1115FractalFlameV14Bent();
    expect(m.id, 'f1115_fractal_flame_v14_bent');
    expect(m.shader, 'shaders/f1115_fractal_flame_v14_bent_gpu.frag');
  });

  test('F1115FractalFlameV14Bent presets are well-formed', () {
    final m = F1115FractalFlameV14Bent();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1115FractalFlameV14Bent metadata is consistent', () {
    final m = F1115FractalFlameV14Bent();
    expect(m.metadata.id, m.id);
  });
}

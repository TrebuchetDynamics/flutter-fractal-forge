// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1141_fractal_flame_v40_rectangles/f1141_fractal_flame_v40_rectangles_module.dart';

void main() {
  test('F1141FractalFlameV40Rectangles instantiates', () {
    final m = F1141FractalFlameV40Rectangles();
    expect(m.id, 'f1141_fractal_flame_v40_rectangles');
    expect(m.shader, 'shaders/f1141_fractal_flame_v40_rectangles_gpu.frag');
  });

  test('F1141FractalFlameV40Rectangles presets are well-formed', () {
    final m = F1141FractalFlameV40Rectangles();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1141FractalFlameV40Rectangles metadata is consistent', () {
    final m = F1141FractalFlameV40Rectangles();
    expect(m.metadata.id, m.id);
  });
}

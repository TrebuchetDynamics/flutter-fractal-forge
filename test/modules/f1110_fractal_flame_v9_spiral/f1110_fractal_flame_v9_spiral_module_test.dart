// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1110_fractal_flame_v9_spiral/f1110_fractal_flame_v9_spiral_module.dart';

void main() {
  test('F1110FractalFlameV9Spiral instantiates', () {
    final m = F1110FractalFlameV9Spiral();
    expect(m.id, 'f1110_fractal_flame_v9_spiral');
    expect(m.shader, 'shaders/f1110_fractal_flame_v9_spiral_gpu.frag');
  });

  test('F1110FractalFlameV9Spiral presets are well-formed', () {
    final m = F1110FractalFlameV9Spiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1110FractalFlameV9Spiral metadata is consistent', () {
    final m = F1110FractalFlameV9Spiral();
    expect(m.metadata.id, m.id);
  });
}

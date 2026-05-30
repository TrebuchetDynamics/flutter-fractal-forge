// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1108_fractal_flame_v7_heart/f1108_fractal_flame_v7_heart_module.dart';

void main() {
  test('F1108FractalFlameV7Heart instantiates', () {
    final m = F1108FractalFlameV7Heart();
    expect(m.id, 'f1108_fractal_flame_v7_heart');
    expect(m.shader, 'shaders/f1108_fractal_flame_v7_heart_gpu.frag');
  });

  test('F1108FractalFlameV7Heart presets are well-formed', () {
    final m = F1108FractalFlameV7Heart();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1108FractalFlameV7Heart metadata is consistent', () {
    final m = F1108FractalFlameV7Heart();
    expect(m.metadata.id, m.id);
  });
}

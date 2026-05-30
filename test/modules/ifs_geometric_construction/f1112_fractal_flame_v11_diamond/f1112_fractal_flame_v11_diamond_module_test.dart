// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1112_fractal_flame_v11_diamond/f1112_fractal_flame_v11_diamond_module.dart';

void main() {
  test('F1112FractalFlameV11Diamond instantiates', () {
    final m = F1112FractalFlameV11Diamond();
    expect(m.id, 'f1112_fractal_flame_v11_diamond');
    expect(m.shader, 'shaders/f1112_fractal_flame_v11_diamond_gpu.frag');
  });

  test('F1112FractalFlameV11Diamond presets are well-formed', () {
    final m = F1112FractalFlameV11Diamond();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1112FractalFlameV11Diamond metadata is consistent', () {
    final m = F1112FractalFlameV11Diamond();
    expect(m.metadata.id, m.id);
  });
}

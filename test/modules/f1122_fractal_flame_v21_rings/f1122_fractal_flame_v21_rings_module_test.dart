// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1122_fractal_flame_v21_rings/f1122_fractal_flame_v21_rings_module.dart';

void main() {
  test('F1122FractalFlameV21Rings instantiates', () {
    final m = F1122FractalFlameV21Rings();
    expect(m.id, 'f1122_fractal_flame_v21_rings');
    expect(m.shader, 'shaders/f1122_fractal_flame_v21_rings_gpu.frag');
  });

  test('F1122FractalFlameV21Rings presets are well-formed', () {
    final m = F1122FractalFlameV21Rings();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1122FractalFlameV21Rings metadata is consistent', () {
    final m = F1122FractalFlameV21Rings();
    expect(m.metadata.id, m.id);
  });
}

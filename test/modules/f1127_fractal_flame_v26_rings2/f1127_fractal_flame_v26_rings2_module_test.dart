// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1127_fractal_flame_v26_rings2/f1127_fractal_flame_v26_rings2_module.dart';

void main() {
  test('F1127FractalFlameV26Rings2 instantiates', () {
    final m = F1127FractalFlameV26Rings2();
    expect(m.id, 'f1127_fractal_flame_v26_rings2');
    expect(m.shader, 'shaders/f1127_fractal_flame_v26_rings2_gpu.frag');
  });

  test('F1127FractalFlameV26Rings2 presets are well-formed', () {
    final m = F1127FractalFlameV26Rings2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1127FractalFlameV26Rings2 metadata is consistent', () {
    final m = F1127FractalFlameV26Rings2();
    expect(m.metadata.id, m.id);
  });
}

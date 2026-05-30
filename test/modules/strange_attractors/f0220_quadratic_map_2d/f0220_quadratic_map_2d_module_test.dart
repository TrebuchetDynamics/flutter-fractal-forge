// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0220_quadratic_map_2d/f0220_quadratic_map_2d_module.dart';

void main() {
  test('F0220QuadraticMap2d instantiates', () {
    final m = F0220QuadraticMap2d();
    expect(m.id, 'f0220_quadratic_map_2d');
    expect(m.shader, 'shaders/f0220_quadratic_map_2d_gpu.frag');
  });

  test('F0220QuadraticMap2d presets are well-formed', () {
    final m = F0220QuadraticMap2d();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0220QuadraticMap2d metadata is consistent', () {
    final m = F0220QuadraticMap2d();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0847_quadratic_koch_island_type_b/f0847_quadratic_koch_island_type_b_module.dart';

void main() {
  test('F0847QuadraticKochIslandTypeB instantiates', () {
    final m = F0847QuadraticKochIslandTypeB();
    expect(m.id, 'f0847_quadratic_koch_island_type_b');
    expect(m.shader, 'shaders/f0847_quadratic_koch_island_type_b_gpu.frag');
  });

  test('F0847QuadraticKochIslandTypeB presets are well-formed', () {
    final m = F0847QuadraticKochIslandTypeB();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0847QuadraticKochIslandTypeB metadata is consistent', () {
    final m = F0847QuadraticKochIslandTypeB();
    expect(m.metadata.id, m.id);
  });
}

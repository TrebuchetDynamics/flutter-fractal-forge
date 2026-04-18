// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0846_quadratic_koch_island_type_a/f0846_quadratic_koch_island_type_a_module.dart';

void main() {
  test('F0846QuadraticKochIslandTypeA instantiates', () {
    final m = F0846QuadraticKochIslandTypeA();
    expect(m.id, 'f0846_quadratic_koch_island_type_a');
    expect(m.shader, 'shaders/f0846_quadratic_koch_island_type_a_gpu.frag');
  });

  test('F0846QuadraticKochIslandTypeA presets are well-formed', () {
    final m = F0846QuadraticKochIslandTypeA();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0846QuadraticKochIslandTypeA metadata is consistent', () {
    final m = F0846QuadraticKochIslandTypeA();
    expect(m.metadata.id, m.id);
  });
}

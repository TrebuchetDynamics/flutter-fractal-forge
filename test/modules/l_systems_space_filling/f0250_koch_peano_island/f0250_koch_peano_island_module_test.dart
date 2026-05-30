// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0250_koch_peano_island/f0250_koch_peano_island_module.dart';

void main() {
  test('F0250KochPeanoIsland instantiates', () {
    final m = F0250KochPeanoIsland();
    expect(m.id, 'f0250_koch_peano_island');
    expect(m.shader, 'shaders/f0250_koch_peano_island_gpu.frag');
  });

  test('F0250KochPeanoIsland presets are well-formed', () {
    final m = F0250KochPeanoIsland();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0250KochPeanoIsland metadata is consistent', () {
    final m = F0250KochPeanoIsland();
    expect(m.metadata.id, m.id);
  });
}

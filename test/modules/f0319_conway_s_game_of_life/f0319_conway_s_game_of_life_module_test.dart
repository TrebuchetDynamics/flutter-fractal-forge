// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0319_conway_s_game_of_life/f0319_conway_s_game_of_life_module.dart';

void main() {
  test('F0319ConwaySGameOfLife instantiates', () {
    final m = F0319ConwaySGameOfLife();
    expect(m.id, 'f0319_conway_s_game_of_life');
    expect(m.shader, 'shaders/f0319_conway_s_game_of_life_gpu.frag');
  });

  test('F0319ConwaySGameOfLife presets are well-formed', () {
    final m = F0319ConwaySGameOfLife();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0319ConwaySGameOfLife metadata is consistent', () {
    final m = F0319ConwaySGameOfLife();
    expect(m.metadata.id, m.id);
  });
}

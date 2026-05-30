// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0043_sprott_labyrinth_chaos/f0043_sprott_labyrinth_chaos_module.dart';

void main() {
  test('F0043SprottLabyrinthChaos instantiates', () {
    final m = F0043SprottLabyrinthChaos();
    expect(m.id, 'f0043_sprott_labyrinth_chaos');
    expect(m.shader, 'shaders/f0043_sprott_labyrinth_chaos_gpu.frag');
  });

  test('F0043SprottLabyrinthChaos presets are well-formed', () {
    final m = F0043SprottLabyrinthChaos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0043SprottLabyrinthChaos metadata is consistent', () {
    final m = F0043SprottLabyrinthChaos();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0231_heighway_dragon_l_system/f0231_heighway_dragon_l_system_module.dart';

void main() {
  test('F0231HeighwayDragonLSystem instantiates', () {
    final m = F0231HeighwayDragonLSystem();
    expect(m.id, 'f0231_heighway_dragon_l_system');
    expect(m.shader, 'shaders/f0231_heighway_dragon_l_system_gpu.frag');
  });

  test('F0231HeighwayDragonLSystem presets are well-formed', () {
    final m = F0231HeighwayDragonLSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0231HeighwayDragonLSystem metadata is consistent', () {
    final m = F0231HeighwayDragonLSystem();
    expect(m.metadata.id, m.id);
  });
}

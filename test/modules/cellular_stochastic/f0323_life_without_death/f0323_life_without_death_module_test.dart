// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0323_life_without_death/f0323_life_without_death_module.dart';

void main() {
  test('F0323LifeWithoutDeath instantiates', () {
    final m = F0323LifeWithoutDeath();
    expect(m.id, 'f0323_life_without_death');
    expect(m.shader, 'shaders/f0323_life_without_death_gpu.frag');
  });

  test('F0323LifeWithoutDeath presets are well-formed', () {
    final m = F0323LifeWithoutDeath();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0323LifeWithoutDeath metadata is consistent', () {
    final m = F0323LifeWithoutDeath();
    expect(m.metadata.id, m.id);
  });
}

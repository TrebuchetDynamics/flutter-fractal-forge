// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0257_island_and_lakes/f0257_island_and_lakes_module.dart';

void main() {
  test('F0257IslandAndLakes instantiates', () {
    final m = F0257IslandAndLakes();
    expect(m.id, 'f0257_island_and_lakes');
    expect(m.shader, 'shaders/f0257_island_and_lakes_gpu.frag');
  });

  test('F0257IslandAndLakes presets are well-formed', () {
    final m = F0257IslandAndLakes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0257IslandAndLakes metadata is consistent', () {
    final m = F0257IslandAndLakes();
    expect(m.metadata.id, m.id);
  });
}

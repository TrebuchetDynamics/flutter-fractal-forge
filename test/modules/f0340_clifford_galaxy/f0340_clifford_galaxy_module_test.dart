// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0340_clifford_galaxy/f0340_clifford_galaxy_module.dart';

void main() {
  test('F0340CliffordGalaxy instantiates', () {
    final m = F0340CliffordGalaxy();
    expect(m.id, 'f0340_clifford_galaxy');
    expect(m.shader, 'shaders/f0340_clifford_galaxy_gpu.frag');
  });

  test('F0340CliffordGalaxy presets are well-formed', () {
    final m = F0340CliffordGalaxy();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0340CliffordGalaxy metadata is consistent', () {
    final m = F0340CliffordGalaxy();
    expect(m.metadata.id, m.id);
  });
}

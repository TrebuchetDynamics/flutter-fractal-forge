// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0341_clifford_nebula/f0341_clifford_nebula_module.dart';

void main() {
  test('F0341CliffordNebula instantiates', () {
    final m = F0341CliffordNebula();
    expect(m.id, 'f0341_clifford_nebula');
    expect(m.shader, 'shaders/f0341_clifford_nebula_gpu.frag');
  });

  test('F0341CliffordNebula presets are well-formed', () {
    final m = F0341CliffordNebula();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0341CliffordNebula metadata is consistent', () {
    final m = F0341CliffordNebula();
    expect(m.metadata.id, m.id);
  });
}

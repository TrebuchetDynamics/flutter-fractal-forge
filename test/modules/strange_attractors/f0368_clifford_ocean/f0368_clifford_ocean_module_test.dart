// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0368_clifford_ocean/f0368_clifford_ocean_module.dart';

void main() {
  test('F0368CliffordOcean instantiates', () {
    final m = F0368CliffordOcean();
    expect(m.id, 'f0368_clifford_ocean');
    expect(m.shader, 'shaders/f0368_clifford_ocean_gpu.frag');
  });

  test('F0368CliffordOcean presets are well-formed', () {
    final m = F0368CliffordOcean();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0368CliffordOcean metadata is consistent', () {
    final m = F0368CliffordOcean();
    expect(m.metadata.id, m.id);
  });
}

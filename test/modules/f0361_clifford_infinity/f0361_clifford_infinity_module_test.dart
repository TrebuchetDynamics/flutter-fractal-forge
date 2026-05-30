// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0361_clifford_infinity/f0361_clifford_infinity_module.dart';

void main() {
  test('F0361CliffordInfinity instantiates', () {
    final m = F0361CliffordInfinity();
    expect(m.id, 'f0361_clifford_infinity');
    expect(m.shader, 'shaders/f0361_clifford_infinity_gpu.frag');
  });

  test('F0361CliffordInfinity presets are well-formed', () {
    final m = F0361CliffordInfinity();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0361CliffordInfinity metadata is consistent', () {
    final m = F0361CliffordInfinity();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0358_clifford_arms/f0358_clifford_arms_module.dart';

void main() {
  test('F0358CliffordArms instantiates', () {
    final m = F0358CliffordArms();
    expect(m.id, 'f0358_clifford_arms');
    expect(m.shader, 'shaders/f0358_clifford_arms_gpu.frag');
  });

  test('F0358CliffordArms presets are well-formed', () {
    final m = F0358CliffordArms();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0358CliffordArms metadata is consistent', () {
    final m = F0358CliffordArms();
    expect(m.metadata.id, m.id);
  });
}

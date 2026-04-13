// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0344_clifford_ribbon/f0344_clifford_ribbon_module.dart';

void main() {
  test('F0344CliffordRibbon instantiates', () {
    final m = F0344CliffordRibbon();
    expect(m.id, 'f0344_clifford_ribbon');
    expect(m.shader, 'shaders/f0344_clifford_ribbon_gpu.frag');
  });

  test('F0344CliffordRibbon presets are well-formed', () {
    final m = F0344CliffordRibbon();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0344CliffordRibbon metadata is consistent', () {
    final m = F0344CliffordRibbon();
    expect(m.metadata.id, m.id);
  });
}

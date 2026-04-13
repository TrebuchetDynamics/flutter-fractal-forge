// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0367_clifford_veil/f0367_clifford_veil_module.dart';

void main() {
  test('F0367CliffordVeil instantiates', () {
    final m = F0367CliffordVeil();
    expect(m.id, 'f0367_clifford_veil');
    expect(m.shader, 'shaders/f0367_clifford_veil_gpu.frag');
  });

  test('F0367CliffordVeil presets are well-formed', () {
    final m = F0367CliffordVeil();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0367CliffordVeil metadata is consistent', () {
    final m = F0367CliffordVeil();
    expect(m.metadata.id, m.id);
  });
}

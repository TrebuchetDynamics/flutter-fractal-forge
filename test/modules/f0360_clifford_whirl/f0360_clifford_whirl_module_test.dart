// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0360_clifford_whirl/f0360_clifford_whirl_module.dart';

void main() {
  test('F0360CliffordWhirl instantiates', () {
    final m = F0360CliffordWhirl();
    expect(m.id, 'f0360_clifford_whirl');
    expect(m.shader, 'shaders/f0360_clifford_whirl_gpu.frag');
  });

  test('F0360CliffordWhirl presets are well-formed', () {
    final m = F0360CliffordWhirl();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0360CliffordWhirl metadata is consistent', () {
    final m = F0360CliffordWhirl();
    expect(m.metadata.id, m.id);
  });
}

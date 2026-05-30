// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0342_clifford_spirals/f0342_clifford_spirals_module.dart';

void main() {
  test('F0342CliffordSpirals instantiates', () {
    final m = F0342CliffordSpirals();
    expect(m.id, 'f0342_clifford_spirals');
    expect(m.shader, 'shaders/f0342_clifford_spirals_gpu.frag');
  });

  test('F0342CliffordSpirals presets are well-formed', () {
    final m = F0342CliffordSpirals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0342CliffordSpirals metadata is consistent', () {
    final m = F0342CliffordSpirals();
    expect(m.metadata.id, m.id);
  });
}

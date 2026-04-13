// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0366_clifford_hearts/f0366_clifford_hearts_module.dart';

void main() {
  test('F0366CliffordHearts instantiates', () {
    final m = F0366CliffordHearts();
    expect(m.id, 'f0366_clifford_hearts');
    expect(m.shader, 'shaders/f0366_clifford_hearts_gpu.frag');
  });

  test('F0366CliffordHearts presets are well-formed', () {
    final m = F0366CliffordHearts();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0366CliffordHearts metadata is consistent', () {
    final m = F0366CliffordHearts();
    expect(m.metadata.id, m.id);
  });
}

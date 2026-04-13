// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0369_clifford_dunes/f0369_clifford_dunes_module.dart';

void main() {
  test('F0369CliffordDunes instantiates', () {
    final m = F0369CliffordDunes();
    expect(m.id, 'f0369_clifford_dunes');
    expect(m.shader, 'shaders/f0369_clifford_dunes_gpu.frag');
  });

  test('F0369CliffordDunes presets are well-formed', () {
    final m = F0369CliffordDunes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0369CliffordDunes metadata is consistent', () {
    final m = F0369CliffordDunes();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0339_clifford_butterfly/f0339_clifford_butterfly_module.dart';

void main() {
  test('F0339CliffordButterfly instantiates', () {
    final m = F0339CliffordButterfly();
    expect(m.id, 'f0339_clifford_butterfly');
    expect(m.shader, 'shaders/f0339_clifford_butterfly_gpu.frag');
  });

  test('F0339CliffordButterfly presets are well-formed', () {
    final m = F0339CliffordButterfly();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0339CliffordButterfly metadata is consistent', () {
    final m = F0339CliffordButterfly();
    expect(m.metadata.id, m.id);
  });
}

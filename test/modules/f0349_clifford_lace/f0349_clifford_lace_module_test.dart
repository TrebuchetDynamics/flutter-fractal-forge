// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0349_clifford_lace/f0349_clifford_lace_module.dart';

void main() {
  test('F0349CliffordLace instantiates', () {
    final m = F0349CliffordLace();
    expect(m.id, 'f0349_clifford_lace');
    expect(m.shader, 'shaders/f0349_clifford_lace_gpu.frag');
  });

  test('F0349CliffordLace presets are well-formed', () {
    final m = F0349CliffordLace();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0349CliffordLace metadata is consistent', () {
    final m = F0349CliffordLace();
    expect(m.metadata.id, m.id);
  });
}

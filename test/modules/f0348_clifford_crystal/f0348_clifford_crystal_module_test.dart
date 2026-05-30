// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0348_clifford_crystal/f0348_clifford_crystal_module.dart';

void main() {
  test('F0348CliffordCrystal instantiates', () {
    final m = F0348CliffordCrystal();
    expect(m.id, 'f0348_clifford_crystal');
    expect(m.shader, 'shaders/f0348_clifford_crystal_gpu.frag');
  });

  test('F0348CliffordCrystal presets are well-formed', () {
    final m = F0348CliffordCrystal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0348CliffordCrystal metadata is consistent', () {
    final m = F0348CliffordCrystal();
    expect(m.metadata.id, m.id);
  });
}

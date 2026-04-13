// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0353_clifford_rose/f0353_clifford_rose_module.dart';

void main() {
  test('F0353CliffordRose instantiates', () {
    final m = F0353CliffordRose();
    expect(m.id, 'f0353_clifford_rose');
    expect(m.shader, 'shaders/f0353_clifford_rose_gpu.frag');
  });

  test('F0353CliffordRose presets are well-formed', () {
    final m = F0353CliffordRose();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0353CliffordRose metadata is consistent', () {
    final m = F0353CliffordRose();
    expect(m.metadata.id, m.id);
  });
}

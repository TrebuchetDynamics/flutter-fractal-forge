// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0351_clifford_star/f0351_clifford_star_module.dart';

void main() {
  test('F0351CliffordStar instantiates', () {
    final m = F0351CliffordStar();
    expect(m.id, 'f0351_clifford_star');
    expect(m.shader, 'shaders/f0351_clifford_star_gpu.frag');
  });

  test('F0351CliffordStar presets are well-formed', () {
    final m = F0351CliffordStar();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0351CliffordStar metadata is consistent', () {
    final m = F0351CliffordStar();
    expect(m.metadata.id, m.id);
  });
}

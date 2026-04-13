// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0346_clifford_vortex/f0346_clifford_vortex_module.dart';

void main() {
  test('F0346CliffordVortex instantiates', () {
    final m = F0346CliffordVortex();
    expect(m.id, 'f0346_clifford_vortex');
    expect(m.shader, 'shaders/f0346_clifford_vortex_gpu.frag');
  });

  test('F0346CliffordVortex presets are well-formed', () {
    final m = F0346CliffordVortex();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0346CliffordVortex metadata is consistent', () {
    final m = F0346CliffordVortex();
    expect(m.metadata.id, m.id);
  });
}

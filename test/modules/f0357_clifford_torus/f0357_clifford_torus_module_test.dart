// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0357_clifford_torus/f0357_clifford_torus_module.dart';

void main() {
  test('F0357CliffordTorus instantiates', () {
    final m = F0357CliffordTorus();
    expect(m.id, 'f0357_clifford_torus');
    expect(m.shader, 'shaders/f0357_clifford_torus_gpu.frag');
  });

  test('F0357CliffordTorus presets are well-formed', () {
    final m = F0357CliffordTorus();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0357CliffordTorus metadata is consistent', () {
    final m = F0357CliffordTorus();
    expect(m.metadata.id, m.id);
  });
}

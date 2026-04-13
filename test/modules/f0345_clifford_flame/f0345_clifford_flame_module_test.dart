// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0345_clifford_flame/f0345_clifford_flame_module.dart';

void main() {
  test('F0345CliffordFlame instantiates', () {
    final m = F0345CliffordFlame();
    expect(m.id, 'f0345_clifford_flame');
    expect(m.shader, 'shaders/f0345_clifford_flame_gpu.frag');
  });

  test('F0345CliffordFlame presets are well-formed', () {
    final m = F0345CliffordFlame();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0345CliffordFlame metadata is consistent', () {
    final m = F0345CliffordFlame();
    expect(m.metadata.id, m.id);
  });
}

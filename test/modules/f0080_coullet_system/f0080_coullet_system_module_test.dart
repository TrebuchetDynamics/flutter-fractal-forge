// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0080_coullet_system/f0080_coullet_system_module.dart';

void main() {
  test('F0080CoulletSystem instantiates', () {
    final m = F0080CoulletSystem();
    expect(m.id, 'f0080_coullet_system');
    expect(m.shader, 'shaders/f0080_coullet_system_gpu.frag');
  });

  test('F0080CoulletSystem presets are well-formed', () {
    final m = F0080CoulletSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0080CoulletSystem metadata is consistent', () {
    final m = F0080CoulletSystem();
    expect(m.metadata.id, m.id);
  });
}

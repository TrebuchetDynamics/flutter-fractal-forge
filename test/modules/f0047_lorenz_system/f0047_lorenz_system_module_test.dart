// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0047_lorenz_system/f0047_lorenz_system_module.dart';

void main() {
  test('F0047LorenzSystem instantiates', () {
    final m = F0047LorenzSystem();
    expect(m.id, 'f0047_lorenz_system');
    expect(m.shader, 'shaders/f0047_lorenz_system_gpu.frag');
  });

  test('F0047LorenzSystem presets are well-formed', () {
    final m = F0047LorenzSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0047LorenzSystem metadata is consistent', () {
    final m = F0047LorenzSystem();
    expect(m.metadata.id, m.id);
  });
}

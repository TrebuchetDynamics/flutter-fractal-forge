// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0073_liu_chaotic_system/f0073_liu_chaotic_system_module.dart';

void main() {
  test('F0073LiuChaoticSystem instantiates', () {
    final m = F0073LiuChaoticSystem();
    expect(m.id, 'f0073_liu_chaotic_system');
    expect(m.shader, 'shaders/f0073_liu_chaotic_system_gpu.frag');
  });

  test('F0073LiuChaoticSystem presets are well-formed', () {
    final m = F0073LiuChaoticSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0073LiuChaoticSystem metadata is consistent', () {
    final m = F0073LiuChaoticSystem();
    expect(m.metadata.id, m.id);
  });
}

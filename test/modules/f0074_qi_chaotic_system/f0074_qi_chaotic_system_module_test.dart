// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0074_qi_chaotic_system/f0074_qi_chaotic_system_module.dart';

void main() {
  test('F0074QiChaoticSystem instantiates', () {
    final m = F0074QiChaoticSystem();
    expect(m.id, 'f0074_qi_chaotic_system');
    expect(m.shader, 'shaders/f0074_qi_chaotic_system_gpu.frag');
  });

  test('F0074QiChaoticSystem presets are well-formed', () {
    final m = F0074QiChaoticSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0074QiChaoticSystem metadata is consistent', () {
    final m = F0074QiChaoticSystem();
    expect(m.metadata.id, m.id);
  });
}

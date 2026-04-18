// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0804_logistic_chaos_r_3_8/f0804_logistic_chaos_r_3_8_module.dart';

void main() {
  test('F0804LogisticChaosR38 instantiates', () {
    final m = F0804LogisticChaosR38();
    expect(m.id, 'f0804_logistic_chaos_r_3_8');
    expect(m.shader, 'shaders/f0804_logistic_chaos_r_3_8_gpu.frag');
  });

  test('F0804LogisticChaosR38 presets are well-formed', () {
    final m = F0804LogisticChaosR38();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0804LogisticChaosR38 metadata is consistent', () {
    final m = F0804LogisticChaosR38();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0803_logistic_chaos_r_3_7/f0803_logistic_chaos_r_3_7_module.dart';

void main() {
  test('F0803LogisticChaosR37 instantiates', () {
    final m = F0803LogisticChaosR37();
    expect(m.id, 'f0803_logistic_chaos_r_3_7');
    expect(m.shader, 'shaders/f0803_logistic_chaos_r_3_7_gpu.frag');
  });

  test('F0803LogisticChaosR37 presets are well-formed', () {
    final m = F0803LogisticChaosR37();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0803LogisticChaosR37 metadata is consistent', () {
    final m = F0803LogisticChaosR37();
    expect(m.metadata.id, m.id);
  });
}

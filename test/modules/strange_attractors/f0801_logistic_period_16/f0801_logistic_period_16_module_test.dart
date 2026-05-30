// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0801_logistic_period_16/f0801_logistic_period_16_module.dart';

void main() {
  test('F0801LogisticPeriod16 instantiates', () {
    final m = F0801LogisticPeriod16();
    expect(m.id, 'f0801_logistic_period_16');
    expect(m.shader, 'shaders/f0801_logistic_period_16_gpu.frag');
  });

  test('F0801LogisticPeriod16 presets are well-formed', () {
    final m = F0801LogisticPeriod16();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0801LogisticPeriod16 metadata is consistent', () {
    final m = F0801LogisticPeriod16();
    expect(m.metadata.id, m.id);
  });
}

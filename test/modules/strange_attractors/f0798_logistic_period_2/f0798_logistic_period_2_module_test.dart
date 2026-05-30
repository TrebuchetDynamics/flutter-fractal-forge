// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0798_logistic_period_2/f0798_logistic_period_2_module.dart';

void main() {
  test('F0798LogisticPeriod2 instantiates', () {
    final m = F0798LogisticPeriod2();
    expect(m.id, 'f0798_logistic_period_2');
    expect(m.shader, 'shaders/f0798_logistic_period_2_gpu.frag');
  });

  test('F0798LogisticPeriod2 presets are well-formed', () {
    final m = F0798LogisticPeriod2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0798LogisticPeriod2 metadata is consistent', () {
    final m = F0798LogisticPeriod2();
    expect(m.metadata.id, m.id);
  });
}

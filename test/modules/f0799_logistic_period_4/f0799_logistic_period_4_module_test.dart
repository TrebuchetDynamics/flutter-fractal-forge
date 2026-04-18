// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0799_logistic_period_4/f0799_logistic_period_4_module.dart';

void main() {
  test('F0799LogisticPeriod4 instantiates', () {
    final m = F0799LogisticPeriod4();
    expect(m.id, 'f0799_logistic_period_4');
    expect(m.shader, 'shaders/f0799_logistic_period_4_gpu.frag');
  });

  test('F0799LogisticPeriod4 presets are well-formed', () {
    final m = F0799LogisticPeriod4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0799LogisticPeriod4 metadata is consistent', () {
    final m = F0799LogisticPeriod4();
    expect(m.metadata.id, m.id);
  });
}

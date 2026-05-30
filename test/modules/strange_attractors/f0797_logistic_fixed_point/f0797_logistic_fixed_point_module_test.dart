// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0797_logistic_fixed_point/f0797_logistic_fixed_point_module.dart';

void main() {
  test('F0797LogisticFixedPoint instantiates', () {
    final m = F0797LogisticFixedPoint();
    expect(m.id, 'f0797_logistic_fixed_point');
    expect(m.shader, 'shaders/f0797_logistic_fixed_point_gpu.frag');
  });

  test('F0797LogisticFixedPoint presets are well-formed', () {
    final m = F0797LogisticFixedPoint();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0797LogisticFixedPoint metadata is consistent', () {
    final m = F0797LogisticFixedPoint();
    expect(m.metadata.id, m.id);
  });
}

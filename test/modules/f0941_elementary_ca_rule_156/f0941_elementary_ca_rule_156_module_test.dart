// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0941_elementary_ca_rule_156/f0941_elementary_ca_rule_156_module.dart';

void main() {
  test('F0941ElementaryCaRule156 instantiates', () {
    final m = F0941ElementaryCaRule156();
    expect(m.id, 'f0941_elementary_ca_rule_156');
    expect(m.shader, 'shaders/f0941_elementary_ca_rule_156_gpu.frag');
  });

  test('F0941ElementaryCaRule156 presets are well-formed', () {
    final m = F0941ElementaryCaRule156();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0941ElementaryCaRule156 metadata is consistent', () {
    final m = F0941ElementaryCaRule156();
    expect(m.metadata.id, m.id);
  });
}

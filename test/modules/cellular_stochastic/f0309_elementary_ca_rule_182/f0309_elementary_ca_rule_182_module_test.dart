// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0309_elementary_ca_rule_182/f0309_elementary_ca_rule_182_module.dart';

void main() {
  test('F0309ElementaryCaRule182 instantiates', () {
    final m = F0309ElementaryCaRule182();
    expect(m.id, 'f0309_elementary_ca_rule_182');
    expect(m.shader, 'shaders/f0309_elementary_ca_rule_182_gpu.frag');
  });

  test('F0309ElementaryCaRule182 presets are well-formed', () {
    final m = F0309ElementaryCaRule182();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0309ElementaryCaRule182 metadata is consistent', () {
    final m = F0309ElementaryCaRule182();
    expect(m.metadata.id, m.id);
  });
}

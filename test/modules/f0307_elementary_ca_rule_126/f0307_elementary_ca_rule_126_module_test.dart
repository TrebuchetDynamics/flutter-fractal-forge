// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0307_elementary_ca_rule_126/f0307_elementary_ca_rule_126_module.dart';

void main() {
  test('F0307ElementaryCaRule126 instantiates', () {
    final m = F0307ElementaryCaRule126();
    expect(m.id, 'f0307_elementary_ca_rule_126');
    expect(m.shader, 'shaders/f0307_elementary_ca_rule_126_gpu.frag');
  });

  test('F0307ElementaryCaRule126 presets are well-formed', () {
    final m = F0307ElementaryCaRule126();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0307ElementaryCaRule126 metadata is consistent', () {
    final m = F0307ElementaryCaRule126();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0970_elementary_ca_rule_220/f0970_elementary_ca_rule_220_module.dart';

void main() {
  test('F0970ElementaryCaRule220 instantiates', () {
    final m = F0970ElementaryCaRule220();
    expect(m.id, 'f0970_elementary_ca_rule_220');
    expect(m.shader, 'shaders/f0970_elementary_ca_rule_220_gpu.frag');
  });

  test('F0970ElementaryCaRule220 presets are well-formed', () {
    final m = F0970ElementaryCaRule220();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0970ElementaryCaRule220 metadata is consistent', () {
    final m = F0970ElementaryCaRule220();
    expect(m.metadata.id, m.id);
  });
}

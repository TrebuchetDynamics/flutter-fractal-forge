// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0921_elementary_ca_rule_106/f0921_elementary_ca_rule_106_module.dart';

void main() {
  test('F0921ElementaryCaRule106 instantiates', () {
    final m = F0921ElementaryCaRule106();
    expect(m.id, 'f0921_elementary_ca_rule_106');
    expect(m.shader, 'shaders/f0921_elementary_ca_rule_106_gpu.frag');
  });

  test('F0921ElementaryCaRule106 presets are well-formed', () {
    final m = F0921ElementaryCaRule106();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0921ElementaryCaRule106 metadata is consistent', () {
    final m = F0921ElementaryCaRule106();
    expect(m.metadata.id, m.id);
  });
}

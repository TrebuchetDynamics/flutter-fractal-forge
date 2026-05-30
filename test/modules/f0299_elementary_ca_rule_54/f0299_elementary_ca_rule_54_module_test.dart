// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0299_elementary_ca_rule_54/f0299_elementary_ca_rule_54_module.dart';

void main() {
  test('F0299ElementaryCaRule54 instantiates', () {
    final m = F0299ElementaryCaRule54();
    expect(m.id, 'f0299_elementary_ca_rule_54');
    expect(m.shader, 'shaders/f0299_elementary_ca_rule_54_gpu.frag');
  });

  test('F0299ElementaryCaRule54 presets are well-formed', () {
    final m = F0299ElementaryCaRule54();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0299ElementaryCaRule54 metadata is consistent', () {
    final m = F0299ElementaryCaRule54();
    expect(m.metadata.id, m.id);
  });
}

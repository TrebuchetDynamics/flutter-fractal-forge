// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0911_elementary_ca_rule_78/f0911_elementary_ca_rule_78_module.dart';

void main() {
  test('F0911ElementaryCaRule78 instantiates', () {
    final m = F0911ElementaryCaRule78();
    expect(m.id, 'f0911_elementary_ca_rule_78');
    expect(m.shader, 'shaders/f0911_elementary_ca_rule_78_gpu.frag');
  });

  test('F0911ElementaryCaRule78 presets are well-formed', () {
    final m = F0911ElementaryCaRule78();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0911ElementaryCaRule78 metadata is consistent', () {
    final m = F0911ElementaryCaRule78();
    expect(m.metadata.id, m.id);
  });
}

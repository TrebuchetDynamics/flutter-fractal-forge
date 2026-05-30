// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0882_elementary_ca_rule_4/f0882_elementary_ca_rule_4_module.dart';

void main() {
  test('F0882ElementaryCaRule4 instantiates', () {
    final m = F0882ElementaryCaRule4();
    expect(m.id, 'f0882_elementary_ca_rule_4');
    expect(m.shader, 'shaders/f0882_elementary_ca_rule_4_gpu.frag');
  });

  test('F0882ElementaryCaRule4 presets are well-formed', () {
    final m = F0882ElementaryCaRule4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0882ElementaryCaRule4 metadata is consistent', () {
    final m = F0882ElementaryCaRule4();
    expect(m.metadata.id, m.id);
  });
}

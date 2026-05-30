// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0926_elementary_ca_rule_120/f0926_elementary_ca_rule_120_module.dart';

void main() {
  test('F0926ElementaryCaRule120 instantiates', () {
    final m = F0926ElementaryCaRule120();
    expect(m.id, 'f0926_elementary_ca_rule_120');
    expect(m.shader, 'shaders/f0926_elementary_ca_rule_120_gpu.frag');
  });

  test('F0926ElementaryCaRule120 presets are well-formed', () {
    final m = F0926ElementaryCaRule120();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0926ElementaryCaRule120 metadata is consistent', () {
    final m = F0926ElementaryCaRule120();
    expect(m.metadata.id, m.id);
  });
}

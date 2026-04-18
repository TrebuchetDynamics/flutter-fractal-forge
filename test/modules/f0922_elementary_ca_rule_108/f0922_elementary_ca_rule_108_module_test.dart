// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0922_elementary_ca_rule_108/f0922_elementary_ca_rule_108_module.dart';

void main() {
  test('F0922ElementaryCaRule108 instantiates', () {
    final m = F0922ElementaryCaRule108();
    expect(m.id, 'f0922_elementary_ca_rule_108');
    expect(m.shader, 'shaders/f0922_elementary_ca_rule_108_gpu.frag');
  });

  test('F0922ElementaryCaRule108 presets are well-formed', () {
    final m = F0922ElementaryCaRule108();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0922ElementaryCaRule108 metadata is consistent', () {
    final m = F0922ElementaryCaRule108();
    expect(m.metadata.id, m.id);
  });
}

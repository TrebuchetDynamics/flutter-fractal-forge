// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0886_elementary_ca_rule_12/f0886_elementary_ca_rule_12_module.dart';

void main() {
  test('F0886ElementaryCaRule12 instantiates', () {
    final m = F0886ElementaryCaRule12();
    expect(m.id, 'f0886_elementary_ca_rule_12');
    expect(m.shader, 'shaders/f0886_elementary_ca_rule_12_gpu.frag');
  });

  test('F0886ElementaryCaRule12 presets are well-formed', () {
    final m = F0886ElementaryCaRule12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0886ElementaryCaRule12 metadata is consistent', () {
    final m = F0886ElementaryCaRule12();
    expect(m.metadata.id, m.id);
  });
}

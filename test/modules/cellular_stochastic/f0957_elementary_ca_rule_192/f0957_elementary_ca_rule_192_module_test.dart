// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0957_elementary_ca_rule_192/f0957_elementary_ca_rule_192_module.dart';

void main() {
  test('F0957ElementaryCaRule192 instantiates', () {
    final m = F0957ElementaryCaRule192();
    expect(m.id, 'f0957_elementary_ca_rule_192');
    expect(m.shader, 'shaders/f0957_elementary_ca_rule_192_gpu.frag');
  });

  test('F0957ElementaryCaRule192 presets are well-formed', () {
    final m = F0957ElementaryCaRule192();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0957ElementaryCaRule192 metadata is consistent', () {
    final m = F0957ElementaryCaRule192();
    expect(m.metadata.id, m.id);
  });
}

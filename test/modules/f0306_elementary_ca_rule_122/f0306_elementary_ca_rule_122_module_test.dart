// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0306_elementary_ca_rule_122/f0306_elementary_ca_rule_122_module.dart';

void main() {
  test('F0306ElementaryCaRule122 instantiates', () {
    final m = F0306ElementaryCaRule122();
    expect(m.id, 'f0306_elementary_ca_rule_122');
    expect(m.shader, 'shaders/f0306_elementary_ca_rule_122_gpu.frag');
  });

  test('F0306ElementaryCaRule122 presets are well-formed', () {
    final m = F0306ElementaryCaRule122();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0306ElementaryCaRule122 metadata is consistent', () {
    final m = F0306ElementaryCaRule122();
    expect(m.metadata.id, m.id);
  });
}

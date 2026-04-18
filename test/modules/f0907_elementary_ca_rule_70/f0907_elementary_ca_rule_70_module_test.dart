// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0907_elementary_ca_rule_70/f0907_elementary_ca_rule_70_module.dart';

void main() {
  test('F0907ElementaryCaRule70 instantiates', () {
    final m = F0907ElementaryCaRule70();
    expect(m.id, 'f0907_elementary_ca_rule_70');
    expect(m.shader, 'shaders/f0907_elementary_ca_rule_70_gpu.frag');
  });

  test('F0907ElementaryCaRule70 presets are well-formed', () {
    final m = F0907ElementaryCaRule70();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0907ElementaryCaRule70 metadata is consistent', () {
    final m = F0907ElementaryCaRule70();
    expect(m.metadata.id, m.id);
  });
}

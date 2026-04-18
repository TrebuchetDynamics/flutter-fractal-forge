// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0898_elementary_ca_rule_40/f0898_elementary_ca_rule_40_module.dart';

void main() {
  test('F0898ElementaryCaRule40 instantiates', () {
    final m = F0898ElementaryCaRule40();
    expect(m.id, 'f0898_elementary_ca_rule_40');
    expect(m.shader, 'shaders/f0898_elementary_ca_rule_40_gpu.frag');
  });

  test('F0898ElementaryCaRule40 presets are well-formed', () {
    final m = F0898ElementaryCaRule40();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0898ElementaryCaRule40 metadata is consistent', () {
    final m = F0898ElementaryCaRule40();
    expect(m.metadata.id, m.id);
  });
}

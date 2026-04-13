// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0311_elementary_ca_rule_22/f0311_elementary_ca_rule_22_module.dart';

void main() {
  test('F0311ElementaryCaRule22 instantiates', () {
    final m = F0311ElementaryCaRule22();
    expect(m.id, 'f0311_elementary_ca_rule_22');
    expect(m.shader, 'shaders/f0311_elementary_ca_rule_22_gpu.frag');
  });

  test('F0311ElementaryCaRule22 presets are well-formed', () {
    final m = F0311ElementaryCaRule22();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0311ElementaryCaRule22 metadata is consistent', () {
    final m = F0311ElementaryCaRule22();
    expect(m.metadata.id, m.id);
  });
}

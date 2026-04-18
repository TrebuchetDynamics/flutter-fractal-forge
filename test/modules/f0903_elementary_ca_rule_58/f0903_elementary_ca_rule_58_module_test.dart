// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0903_elementary_ca_rule_58/f0903_elementary_ca_rule_58_module.dart';

void main() {
  test('F0903ElementaryCaRule58 instantiates', () {
    final m = F0903ElementaryCaRule58();
    expect(m.id, 'f0903_elementary_ca_rule_58');
    expect(m.shader, 'shaders/f0903_elementary_ca_rule_58_gpu.frag');
  });

  test('F0903ElementaryCaRule58 presets are well-formed', () {
    final m = F0903ElementaryCaRule58();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0903ElementaryCaRule58 metadata is consistent', () {
    final m = F0903ElementaryCaRule58();
    expect(m.metadata.id, m.id);
  });
}

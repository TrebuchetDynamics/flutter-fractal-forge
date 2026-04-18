// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0895_elementary_ca_rule_34/f0895_elementary_ca_rule_34_module.dart';

void main() {
  test('F0895ElementaryCaRule34 instantiates', () {
    final m = F0895ElementaryCaRule34();
    expect(m.id, 'f0895_elementary_ca_rule_34');
    expect(m.shader, 'shaders/f0895_elementary_ca_rule_34_gpu.frag');
  });

  test('F0895ElementaryCaRule34 presets are well-formed', () {
    final m = F0895ElementaryCaRule34();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0895ElementaryCaRule34 metadata is consistent', () {
    final m = F0895ElementaryCaRule34();
    expect(m.metadata.id, m.id);
  });
}

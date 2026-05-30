// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0924_elementary_ca_rule_114/f0924_elementary_ca_rule_114_module.dart';

void main() {
  test('F0924ElementaryCaRule114 instantiates', () {
    final m = F0924ElementaryCaRule114();
    expect(m.id, 'f0924_elementary_ca_rule_114');
    expect(m.shader, 'shaders/f0924_elementary_ca_rule_114_gpu.frag');
  });

  test('F0924ElementaryCaRule114 presets are well-formed', () {
    final m = F0924ElementaryCaRule114();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0924ElementaryCaRule114 metadata is consistent', () {
    final m = F0924ElementaryCaRule114();
    expect(m.metadata.id, m.id);
  });
}

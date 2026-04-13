// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0310_elementary_ca_rule_184/f0310_elementary_ca_rule_184_module.dart';

void main() {
  test('F0310ElementaryCaRule184 instantiates', () {
    final m = F0310ElementaryCaRule184();
    expect(m.id, 'f0310_elementary_ca_rule_184');
    expect(m.shader, 'shaders/f0310_elementary_ca_rule_184_gpu.frag');
  });

  test('F0310ElementaryCaRule184 presets are well-formed', () {
    final m = F0310ElementaryCaRule184();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0310ElementaryCaRule184 metadata is consistent', () {
    final m = F0310ElementaryCaRule184();
    expect(m.metadata.id, m.id);
  });
}

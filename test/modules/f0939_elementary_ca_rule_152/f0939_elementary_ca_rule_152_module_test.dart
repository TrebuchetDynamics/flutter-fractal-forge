// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0939_elementary_ca_rule_152/f0939_elementary_ca_rule_152_module.dart';

void main() {
  test('F0939ElementaryCaRule152 instantiates', () {
    final m = F0939ElementaryCaRule152();
    expect(m.id, 'f0939_elementary_ca_rule_152');
    expect(m.shader, 'shaders/f0939_elementary_ca_rule_152_gpu.frag');
  });

  test('F0939ElementaryCaRule152 presets are well-formed', () {
    final m = F0939ElementaryCaRule152();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0939ElementaryCaRule152 metadata is consistent', () {
    final m = F0939ElementaryCaRule152();
    expect(m.metadata.id, m.id);
  });
}

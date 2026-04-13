// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0315_elementary_ca_rule_105/f0315_elementary_ca_rule_105_module.dart';

void main() {
  test('F0315ElementaryCaRule105 instantiates', () {
    final m = F0315ElementaryCaRule105();
    expect(m.id, 'f0315_elementary_ca_rule_105');
    expect(m.shader, 'shaders/f0315_elementary_ca_rule_105_gpu.frag');
  });

  test('F0315ElementaryCaRule105 presets are well-formed', () {
    final m = F0315ElementaryCaRule105();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0315ElementaryCaRule105 metadata is consistent', () {
    final m = F0315ElementaryCaRule105();
    expect(m.metadata.id, m.id);
  });
}

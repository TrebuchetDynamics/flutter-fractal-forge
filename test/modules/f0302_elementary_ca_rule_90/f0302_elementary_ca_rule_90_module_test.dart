// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0302_elementary_ca_rule_90/f0302_elementary_ca_rule_90_module.dart';

void main() {
  test('F0302ElementaryCaRule90 instantiates', () {
    final m = F0302ElementaryCaRule90();
    expect(m.id, 'f0302_elementary_ca_rule_90');
    expect(m.shader, 'shaders/f0302_elementary_ca_rule_90_gpu.frag');
  });

  test('F0302ElementaryCaRule90 presets are well-formed', () {
    final m = F0302ElementaryCaRule90();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0302ElementaryCaRule90 metadata is consistent', () {
    final m = F0302ElementaryCaRule90();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0305_elementary_ca_rule_110/f0305_elementary_ca_rule_110_module.dart';

void main() {
  test('F0305ElementaryCaRule110 instantiates', () {
    final m = F0305ElementaryCaRule110();
    expect(m.id, 'f0305_elementary_ca_rule_110');
    expect(m.shader, 'shaders/f0305_elementary_ca_rule_110_gpu.frag');
  });

  test('F0305ElementaryCaRule110 presets are well-formed', () {
    final m = F0305ElementaryCaRule110();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0305ElementaryCaRule110 metadata is consistent', () {
    final m = F0305ElementaryCaRule110();
    expect(m.metadata.id, m.id);
  });
}

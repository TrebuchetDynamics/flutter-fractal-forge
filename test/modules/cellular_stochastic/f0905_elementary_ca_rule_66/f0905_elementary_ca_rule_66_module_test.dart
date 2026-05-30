// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0905_elementary_ca_rule_66/f0905_elementary_ca_rule_66_module.dart';

void main() {
  test('F0905ElementaryCaRule66 instantiates', () {
    final m = F0905ElementaryCaRule66();
    expect(m.id, 'f0905_elementary_ca_rule_66');
    expect(m.shader, 'shaders/f0905_elementary_ca_rule_66_gpu.frag');
  });

  test('F0905ElementaryCaRule66 presets are well-formed', () {
    final m = F0905ElementaryCaRule66();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0905ElementaryCaRule66 metadata is consistent', () {
    final m = F0905ElementaryCaRule66();
    expect(m.metadata.id, m.id);
  });
}

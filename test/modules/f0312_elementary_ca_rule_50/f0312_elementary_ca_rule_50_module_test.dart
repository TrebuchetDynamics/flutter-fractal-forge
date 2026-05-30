// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0312_elementary_ca_rule_50/f0312_elementary_ca_rule_50_module.dart';

void main() {
  test('F0312ElementaryCaRule50 instantiates', () {
    final m = F0312ElementaryCaRule50();
    expect(m.id, 'f0312_elementary_ca_rule_50');
    expect(m.shader, 'shaders/f0312_elementary_ca_rule_50_gpu.frag');
  });

  test('F0312ElementaryCaRule50 presets are well-formed', () {
    final m = F0312ElementaryCaRule50();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0312ElementaryCaRule50 metadata is consistent', () {
    final m = F0312ElementaryCaRule50();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0883_elementary_ca_rule_6/f0883_elementary_ca_rule_6_module.dart';

void main() {
  test('F0883ElementaryCaRule6 instantiates', () {
    final m = F0883ElementaryCaRule6();
    expect(m.id, 'f0883_elementary_ca_rule_6');
    expect(m.shader, 'shaders/f0883_elementary_ca_rule_6_gpu.frag');
  });

  test('F0883ElementaryCaRule6 presets are well-formed', () {
    final m = F0883ElementaryCaRule6();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0883ElementaryCaRule6 metadata is consistent', () {
    final m = F0883ElementaryCaRule6();
    expect(m.metadata.id, m.id);
  });
}

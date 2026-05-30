// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0899_elementary_ca_rule_42/f0899_elementary_ca_rule_42_module.dart';

void main() {
  test('F0899ElementaryCaRule42 instantiates', () {
    final m = F0899ElementaryCaRule42();
    expect(m.id, 'f0899_elementary_ca_rule_42');
    expect(m.shader, 'shaders/f0899_elementary_ca_rule_42_gpu.frag');
  });

  test('F0899ElementaryCaRule42 presets are well-formed', () {
    final m = F0899ElementaryCaRule42();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0899ElementaryCaRule42 metadata is consistent', () {
    final m = F0899ElementaryCaRule42();
    expect(m.metadata.id, m.id);
  });
}

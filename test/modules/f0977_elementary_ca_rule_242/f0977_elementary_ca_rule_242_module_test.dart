// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0977_elementary_ca_rule_242/f0977_elementary_ca_rule_242_module.dart';

void main() {
  test('F0977ElementaryCaRule242 instantiates', () {
    final m = F0977ElementaryCaRule242();
    expect(m.id, 'f0977_elementary_ca_rule_242');
    expect(m.shader, 'shaders/f0977_elementary_ca_rule_242_gpu.frag');
  });

  test('F0977ElementaryCaRule242 presets are well-formed', () {
    final m = F0977ElementaryCaRule242();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0977ElementaryCaRule242 metadata is consistent', () {
    final m = F0977ElementaryCaRule242();
    expect(m.metadata.id, m.id);
  });
}

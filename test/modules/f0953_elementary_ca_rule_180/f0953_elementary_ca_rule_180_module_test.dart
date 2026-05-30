// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0953_elementary_ca_rule_180/f0953_elementary_ca_rule_180_module.dart';

void main() {
  test('F0953ElementaryCaRule180 instantiates', () {
    final m = F0953ElementaryCaRule180();
    expect(m.id, 'f0953_elementary_ca_rule_180');
    expect(m.shader, 'shaders/f0953_elementary_ca_rule_180_gpu.frag');
  });

  test('F0953ElementaryCaRule180 presets are well-formed', () {
    final m = F0953ElementaryCaRule180();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0953ElementaryCaRule180 metadata is consistent', () {
    final m = F0953ElementaryCaRule180();
    expect(m.metadata.id, m.id);
  });
}

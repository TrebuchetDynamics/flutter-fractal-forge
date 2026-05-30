// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0969_elementary_ca_rule_218/f0969_elementary_ca_rule_218_module.dart';

void main() {
  test('F0969ElementaryCaRule218 instantiates', () {
    final m = F0969ElementaryCaRule218();
    expect(m.id, 'f0969_elementary_ca_rule_218');
    expect(m.shader, 'shaders/f0969_elementary_ca_rule_218_gpu.frag');
  });

  test('F0969ElementaryCaRule218 presets are well-formed', () {
    final m = F0969ElementaryCaRule218();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0969ElementaryCaRule218 metadata is consistent', () {
    final m = F0969ElementaryCaRule218();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0890_elementary_ca_rule_20/f0890_elementary_ca_rule_20_module.dart';

void main() {
  test('F0890ElementaryCaRule20 instantiates', () {
    final m = F0890ElementaryCaRule20();
    expect(m.id, 'f0890_elementary_ca_rule_20');
    expect(m.shader, 'shaders/f0890_elementary_ca_rule_20_gpu.frag');
  });

  test('F0890ElementaryCaRule20 presets are well-formed', () {
    final m = F0890ElementaryCaRule20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0890ElementaryCaRule20 metadata is consistent', () {
    final m = F0890ElementaryCaRule20();
    expect(m.metadata.id, m.id);
  });
}

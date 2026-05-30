// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0975_elementary_ca_rule_234/f0975_elementary_ca_rule_234_module.dart';

void main() {
  test('F0975ElementaryCaRule234 instantiates', () {
    final m = F0975ElementaryCaRule234();
    expect(m.id, 'f0975_elementary_ca_rule_234');
    expect(m.shader, 'shaders/f0975_elementary_ca_rule_234_gpu.frag');
  });

  test('F0975ElementaryCaRule234 presets are well-formed', () {
    final m = F0975ElementaryCaRule234();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0975ElementaryCaRule234 metadata is consistent', () {
    final m = F0975ElementaryCaRule234();
    expect(m.metadata.id, m.id);
  });
}

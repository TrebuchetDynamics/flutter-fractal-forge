// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0303_elementary_ca_rule_94/f0303_elementary_ca_rule_94_module.dart';

void main() {
  test('F0303ElementaryCaRule94 instantiates', () {
    final m = F0303ElementaryCaRule94();
    expect(m.id, 'f0303_elementary_ca_rule_94');
    expect(m.shader, 'shaders/f0303_elementary_ca_rule_94_gpu.frag');
  });

  test('F0303ElementaryCaRule94 presets are well-formed', () {
    final m = F0303ElementaryCaRule94();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0303ElementaryCaRule94 metadata is consistent', () {
    final m = F0303ElementaryCaRule94();
    expect(m.metadata.id, m.id);
  });
}

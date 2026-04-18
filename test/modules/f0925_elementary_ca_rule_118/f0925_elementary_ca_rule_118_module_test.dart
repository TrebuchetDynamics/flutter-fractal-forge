// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0925_elementary_ca_rule_118/f0925_elementary_ca_rule_118_module.dart';

void main() {
  test('F0925ElementaryCaRule118 instantiates', () {
    final m = F0925ElementaryCaRule118();
    expect(m.id, 'f0925_elementary_ca_rule_118');
    expect(m.shader, 'shaders/f0925_elementary_ca_rule_118_gpu.frag');
  });

  test('F0925ElementaryCaRule118 presets are well-formed', () {
    final m = F0925ElementaryCaRule118();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0925ElementaryCaRule118 metadata is consistent', () {
    final m = F0925ElementaryCaRule118();
    expect(m.metadata.id, m.id);
  });
}

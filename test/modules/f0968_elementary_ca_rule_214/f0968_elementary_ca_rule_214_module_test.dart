// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0968_elementary_ca_rule_214/f0968_elementary_ca_rule_214_module.dart';

void main() {
  test('F0968ElementaryCaRule214 instantiates', () {
    final m = F0968ElementaryCaRule214();
    expect(m.id, 'f0968_elementary_ca_rule_214');
    expect(m.shader, 'shaders/f0968_elementary_ca_rule_214_gpu.frag');
  });

  test('F0968ElementaryCaRule214 presets are well-formed', () {
    final m = F0968ElementaryCaRule214();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0968ElementaryCaRule214 metadata is consistent', () {
    final m = F0968ElementaryCaRule214();
    expect(m.metadata.id, m.id);
  });
}

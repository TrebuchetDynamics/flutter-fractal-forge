// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0304_elementary_ca_rule_102/f0304_elementary_ca_rule_102_module.dart';

void main() {
  test('F0304ElementaryCaRule102 instantiates', () {
    final m = F0304ElementaryCaRule102();
    expect(m.id, 'f0304_elementary_ca_rule_102');
    expect(m.shader, 'shaders/f0304_elementary_ca_rule_102_gpu.frag');
  });

  test('F0304ElementaryCaRule102 presets are well-formed', () {
    final m = F0304ElementaryCaRule102();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0304ElementaryCaRule102 metadata is consistent', () {
    final m = F0304ElementaryCaRule102();
    expect(m.metadata.id, m.id);
  });
}

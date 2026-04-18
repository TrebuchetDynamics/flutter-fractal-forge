// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0908_elementary_ca_rule_72/f0908_elementary_ca_rule_72_module.dart';

void main() {
  test('F0908ElementaryCaRule72 instantiates', () {
    final m = F0908ElementaryCaRule72();
    expect(m.id, 'f0908_elementary_ca_rule_72');
    expect(m.shader, 'shaders/f0908_elementary_ca_rule_72_gpu.frag');
  });

  test('F0908ElementaryCaRule72 presets are well-formed', () {
    final m = F0908ElementaryCaRule72();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0908ElementaryCaRule72 metadata is consistent', () {
    final m = F0908ElementaryCaRule72();
    expect(m.metadata.id, m.id);
  });
}

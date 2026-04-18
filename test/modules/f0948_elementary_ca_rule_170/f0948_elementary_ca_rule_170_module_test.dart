// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0948_elementary_ca_rule_170/f0948_elementary_ca_rule_170_module.dart';

void main() {
  test('F0948ElementaryCaRule170 instantiates', () {
    final m = F0948ElementaryCaRule170();
    expect(m.id, 'f0948_elementary_ca_rule_170');
    expect(m.shader, 'shaders/f0948_elementary_ca_rule_170_gpu.frag');
  });

  test('F0948ElementaryCaRule170 presets are well-formed', () {
    final m = F0948ElementaryCaRule170();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0948ElementaryCaRule170 metadata is consistent', () {
    final m = F0948ElementaryCaRule170();
    expect(m.metadata.id, m.id);
  });
}

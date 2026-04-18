// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0960_elementary_ca_rule_198/f0960_elementary_ca_rule_198_module.dart';

void main() {
  test('F0960ElementaryCaRule198 instantiates', () {
    final m = F0960ElementaryCaRule198();
    expect(m.id, 'f0960_elementary_ca_rule_198');
    expect(m.shader, 'shaders/f0960_elementary_ca_rule_198_gpu.frag');
  });

  test('F0960ElementaryCaRule198 presets are well-formed', () {
    final m = F0960ElementaryCaRule198();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0960ElementaryCaRule198 metadata is consistent', () {
    final m = F0960ElementaryCaRule198();
    expect(m.metadata.id, m.id);
  });
}

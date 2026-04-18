// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0891_elementary_ca_rule_24/f0891_elementary_ca_rule_24_module.dart';

void main() {
  test('F0891ElementaryCaRule24 instantiates', () {
    final m = F0891ElementaryCaRule24();
    expect(m.id, 'f0891_elementary_ca_rule_24');
    expect(m.shader, 'shaders/f0891_elementary_ca_rule_24_gpu.frag');
  });

  test('F0891ElementaryCaRule24 presets are well-formed', () {
    final m = F0891ElementaryCaRule24();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0891ElementaryCaRule24 metadata is consistent', () {
    final m = F0891ElementaryCaRule24();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0935_elementary_ca_rule_142/f0935_elementary_ca_rule_142_module.dart';

void main() {
  test('F0935ElementaryCaRule142 instantiates', () {
    final m = F0935ElementaryCaRule142();
    expect(m.id, 'f0935_elementary_ca_rule_142');
    expect(m.shader, 'shaders/f0935_elementary_ca_rule_142_gpu.frag');
  });

  test('F0935ElementaryCaRule142 presets are well-formed', () {
    final m = F0935ElementaryCaRule142();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0935ElementaryCaRule142 metadata is consistent', () {
    final m = F0935ElementaryCaRule142();
    expect(m.metadata.id, m.id);
  });
}

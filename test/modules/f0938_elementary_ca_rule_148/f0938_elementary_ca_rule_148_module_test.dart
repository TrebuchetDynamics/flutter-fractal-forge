// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0938_elementary_ca_rule_148/f0938_elementary_ca_rule_148_module.dart';

void main() {
  test('F0938ElementaryCaRule148 instantiates', () {
    final m = F0938ElementaryCaRule148();
    expect(m.id, 'f0938_elementary_ca_rule_148');
    expect(m.shader, 'shaders/f0938_elementary_ca_rule_148_gpu.frag');
  });

  test('F0938ElementaryCaRule148 presets are well-formed', () {
    final m = F0938ElementaryCaRule148();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0938ElementaryCaRule148 metadata is consistent', () {
    final m = F0938ElementaryCaRule148();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0959_elementary_ca_rule_196/f0959_elementary_ca_rule_196_module.dart';

void main() {
  test('F0959ElementaryCaRule196 instantiates', () {
    final m = F0959ElementaryCaRule196();
    expect(m.id, 'f0959_elementary_ca_rule_196');
    expect(m.shader, 'shaders/f0959_elementary_ca_rule_196_gpu.frag');
  });

  test('F0959ElementaryCaRule196 presets are well-formed', () {
    final m = F0959ElementaryCaRule196();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0959ElementaryCaRule196 metadata is consistent', () {
    final m = F0959ElementaryCaRule196();
    expect(m.metadata.id, m.id);
  });
}

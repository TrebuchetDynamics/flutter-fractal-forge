// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0934_elementary_ca_rule_140/f0934_elementary_ca_rule_140_module.dart';

void main() {
  test('F0934ElementaryCaRule140 instantiates', () {
    final m = F0934ElementaryCaRule140();
    expect(m.id, 'f0934_elementary_ca_rule_140');
    expect(m.shader, 'shaders/f0934_elementary_ca_rule_140_gpu.frag');
  });

  test('F0934ElementaryCaRule140 presets are well-formed', () {
    final m = F0934ElementaryCaRule140();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0934ElementaryCaRule140 metadata is consistent', () {
    final m = F0934ElementaryCaRule140();
    expect(m.metadata.id, m.id);
  });
}

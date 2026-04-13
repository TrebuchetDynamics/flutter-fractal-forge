// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0300_elementary_ca_rule_62/f0300_elementary_ca_rule_62_module.dart';

void main() {
  test('F0300ElementaryCaRule62 instantiates', () {
    final m = F0300ElementaryCaRule62();
    expect(m.id, 'f0300_elementary_ca_rule_62');
    expect(m.shader, 'shaders/f0300_elementary_ca_rule_62_gpu.frag');
  });

  test('F0300ElementaryCaRule62 presets are well-formed', () {
    final m = F0300ElementaryCaRule62();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0300ElementaryCaRule62 metadata is consistent', () {
    final m = F0300ElementaryCaRule62();
    expect(m.metadata.id, m.id);
  });
}

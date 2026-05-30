// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0952_elementary_ca_rule_178/f0952_elementary_ca_rule_178_module.dart';

void main() {
  test('F0952ElementaryCaRule178 instantiates', () {
    final m = F0952ElementaryCaRule178();
    expect(m.id, 'f0952_elementary_ca_rule_178');
    expect(m.shader, 'shaders/f0952_elementary_ca_rule_178_gpu.frag');
  });

  test('F0952ElementaryCaRule178 presets are well-formed', () {
    final m = F0952ElementaryCaRule178();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0952ElementaryCaRule178 metadata is consistent', () {
    final m = F0952ElementaryCaRule178();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0887_elementary_ca_rule_14/f0887_elementary_ca_rule_14_module.dart';

void main() {
  test('F0887ElementaryCaRule14 instantiates', () {
    final m = F0887ElementaryCaRule14();
    expect(m.id, 'f0887_elementary_ca_rule_14');
    expect(m.shader, 'shaders/f0887_elementary_ca_rule_14_gpu.frag');
  });

  test('F0887ElementaryCaRule14 presets are well-formed', () {
    final m = F0887ElementaryCaRule14();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0887ElementaryCaRule14 metadata is consistent', () {
    final m = F0887ElementaryCaRule14();
    expect(m.metadata.id, m.id);
  });
}

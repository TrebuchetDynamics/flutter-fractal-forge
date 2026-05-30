// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0973_elementary_ca_rule_230/f0973_elementary_ca_rule_230_module.dart';

void main() {
  test('F0973ElementaryCaRule230 instantiates', () {
    final m = F0973ElementaryCaRule230();
    expect(m.id, 'f0973_elementary_ca_rule_230');
    expect(m.shader, 'shaders/f0973_elementary_ca_rule_230_gpu.frag');
  });

  test('F0973ElementaryCaRule230 presets are well-formed', () {
    final m = F0973ElementaryCaRule230();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0973ElementaryCaRule230 metadata is consistent', () {
    final m = F0973ElementaryCaRule230();
    expect(m.metadata.id, m.id);
  });
}

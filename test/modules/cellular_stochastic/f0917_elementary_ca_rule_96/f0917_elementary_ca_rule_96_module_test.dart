// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0917_elementary_ca_rule_96/f0917_elementary_ca_rule_96_module.dart';

void main() {
  test('F0917ElementaryCaRule96 instantiates', () {
    final m = F0917ElementaryCaRule96();
    expect(m.id, 'f0917_elementary_ca_rule_96');
    expect(m.shader, 'shaders/f0917_elementary_ca_rule_96_gpu.frag');
  });

  test('F0917ElementaryCaRule96 presets are well-formed', () {
    final m = F0917ElementaryCaRule96();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0917ElementaryCaRule96 metadata is consistent', () {
    final m = F0917ElementaryCaRule96();
    expect(m.metadata.id, m.id);
  });
}

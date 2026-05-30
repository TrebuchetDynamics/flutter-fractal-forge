// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0881_elementary_ca_rule_2/f0881_elementary_ca_rule_2_module.dart';

void main() {
  test('F0881ElementaryCaRule2 instantiates', () {
    final m = F0881ElementaryCaRule2();
    expect(m.id, 'f0881_elementary_ca_rule_2');
    expect(m.shader, 'shaders/f0881_elementary_ca_rule_2_gpu.frag');
  });

  test('F0881ElementaryCaRule2 presets are well-formed', () {
    final m = F0881ElementaryCaRule2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0881ElementaryCaRule2 metadata is consistent', () {
    final m = F0881ElementaryCaRule2();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0961_elementary_ca_rule_200/f0961_elementary_ca_rule_200_module.dart';

void main() {
  test('F0961ElementaryCaRule200 instantiates', () {
    final m = F0961ElementaryCaRule200();
    expect(m.id, 'f0961_elementary_ca_rule_200');
    expect(m.shader, 'shaders/f0961_elementary_ca_rule_200_gpu.frag');
  });

  test('F0961ElementaryCaRule200 presets are well-formed', () {
    final m = F0961ElementaryCaRule200();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0961ElementaryCaRule200 metadata is consistent', () {
    final m = F0961ElementaryCaRule200();
    expect(m.metadata.id, m.id);
  });
}

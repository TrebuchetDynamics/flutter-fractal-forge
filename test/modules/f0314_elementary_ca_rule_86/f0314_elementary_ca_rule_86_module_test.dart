// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0314_elementary_ca_rule_86/f0314_elementary_ca_rule_86_module.dart';

void main() {
  test('F0314ElementaryCaRule86 instantiates', () {
    final m = F0314ElementaryCaRule86();
    expect(m.id, 'f0314_elementary_ca_rule_86');
    expect(m.shader, 'shaders/f0314_elementary_ca_rule_86_gpu.frag');
  });

  test('F0314ElementaryCaRule86 presets are well-formed', () {
    final m = F0314ElementaryCaRule86();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0314ElementaryCaRule86 metadata is consistent', () {
    final m = F0314ElementaryCaRule86();
    expect(m.metadata.id, m.id);
  });
}

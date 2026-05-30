// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0912_elementary_ca_rule_80/f0912_elementary_ca_rule_80_module.dart';

void main() {
  test('F0912ElementaryCaRule80 instantiates', () {
    final m = F0912ElementaryCaRule80();
    expect(m.id, 'f0912_elementary_ca_rule_80');
    expect(m.shader, 'shaders/f0912_elementary_ca_rule_80_gpu.frag');
  });

  test('F0912ElementaryCaRule80 presets are well-formed', () {
    final m = F0912ElementaryCaRule80();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0912ElementaryCaRule80 metadata is consistent', () {
    final m = F0912ElementaryCaRule80();
    expect(m.metadata.id, m.id);
  });
}

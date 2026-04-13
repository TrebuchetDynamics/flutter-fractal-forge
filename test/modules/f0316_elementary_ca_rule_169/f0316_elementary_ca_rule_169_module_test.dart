// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0316_elementary_ca_rule_169/f0316_elementary_ca_rule_169_module.dart';

void main() {
  test('F0316ElementaryCaRule169 instantiates', () {
    final m = F0316ElementaryCaRule169();
    expect(m.id, 'f0316_elementary_ca_rule_169');
    expect(m.shader, 'shaders/f0316_elementary_ca_rule_169_gpu.frag');
  });

  test('F0316ElementaryCaRule169 presets are well-formed', () {
    final m = F0316ElementaryCaRule169();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0316ElementaryCaRule169 metadata is consistent', () {
    final m = F0316ElementaryCaRule169();
    expect(m.metadata.id, m.id);
  });
}

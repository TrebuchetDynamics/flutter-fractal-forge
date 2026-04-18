// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0918_elementary_ca_rule_98/f0918_elementary_ca_rule_98_module.dart';

void main() {
  test('F0918ElementaryCaRule98 instantiates', () {
    final m = F0918ElementaryCaRule98();
    expect(m.id, 'f0918_elementary_ca_rule_98');
    expect(m.shader, 'shaders/f0918_elementary_ca_rule_98_gpu.frag');
  });

  test('F0918ElementaryCaRule98 presets are well-formed', () {
    final m = F0918ElementaryCaRule98();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0918ElementaryCaRule98 metadata is consistent', () {
    final m = F0918ElementaryCaRule98();
    expect(m.metadata.id, m.id);
  });
}

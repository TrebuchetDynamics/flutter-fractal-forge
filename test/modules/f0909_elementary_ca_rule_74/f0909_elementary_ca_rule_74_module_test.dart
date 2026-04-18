// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0909_elementary_ca_rule_74/f0909_elementary_ca_rule_74_module.dart';

void main() {
  test('F0909ElementaryCaRule74 instantiates', () {
    final m = F0909ElementaryCaRule74();
    expect(m.id, 'f0909_elementary_ca_rule_74');
    expect(m.shader, 'shaders/f0909_elementary_ca_rule_74_gpu.frag');
  });

  test('F0909ElementaryCaRule74 presets are well-formed', () {
    final m = F0909ElementaryCaRule74();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0909ElementaryCaRule74 metadata is consistent', () {
    final m = F0909ElementaryCaRule74();
    expect(m.metadata.id, m.id);
  });
}

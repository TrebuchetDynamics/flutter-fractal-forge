// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0317_elementary_ca_rule_225/f0317_elementary_ca_rule_225_module.dart';

void main() {
  test('F0317ElementaryCaRule225 instantiates', () {
    final m = F0317ElementaryCaRule225();
    expect(m.id, 'f0317_elementary_ca_rule_225');
    expect(m.shader, 'shaders/f0317_elementary_ca_rule_225_gpu.frag');
  });

  test('F0317ElementaryCaRule225 presets are well-formed', () {
    final m = F0317ElementaryCaRule225();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0317ElementaryCaRule225 metadata is consistent', () {
    final m = F0317ElementaryCaRule225();
    expect(m.metadata.id, m.id);
  });
}

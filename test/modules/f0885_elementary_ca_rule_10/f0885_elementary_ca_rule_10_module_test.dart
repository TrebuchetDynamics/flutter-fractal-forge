// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0885_elementary_ca_rule_10/f0885_elementary_ca_rule_10_module.dart';

void main() {
  test('F0885ElementaryCaRule10 instantiates', () {
    final m = F0885ElementaryCaRule10();
    expect(m.id, 'f0885_elementary_ca_rule_10');
    expect(m.shader, 'shaders/f0885_elementary_ca_rule_10_gpu.frag');
  });

  test('F0885ElementaryCaRule10 presets are well-formed', () {
    final m = F0885ElementaryCaRule10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0885ElementaryCaRule10 metadata is consistent', () {
    final m = F0885ElementaryCaRule10();
    expect(m.metadata.id, m.id);
  });
}

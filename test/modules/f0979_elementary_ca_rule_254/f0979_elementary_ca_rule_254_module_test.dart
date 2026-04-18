// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0979_elementary_ca_rule_254/f0979_elementary_ca_rule_254_module.dart';

void main() {
  test('F0979ElementaryCaRule254 instantiates', () {
    final m = F0979ElementaryCaRule254();
    expect(m.id, 'f0979_elementary_ca_rule_254');
    expect(m.shader, 'shaders/f0979_elementary_ca_rule_254_gpu.frag');
  });

  test('F0979ElementaryCaRule254 presets are well-formed', () {
    final m = F0979ElementaryCaRule254();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0979ElementaryCaRule254 metadata is consistent', () {
    final m = F0979ElementaryCaRule254();
    expect(m.metadata.id, m.id);
  });
}

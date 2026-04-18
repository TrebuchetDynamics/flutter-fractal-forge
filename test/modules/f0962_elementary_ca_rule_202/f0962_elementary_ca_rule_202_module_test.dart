// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0962_elementary_ca_rule_202/f0962_elementary_ca_rule_202_module.dart';

void main() {
  test('F0962ElementaryCaRule202 instantiates', () {
    final m = F0962ElementaryCaRule202();
    expect(m.id, 'f0962_elementary_ca_rule_202');
    expect(m.shader, 'shaders/f0962_elementary_ca_rule_202_gpu.frag');
  });

  test('F0962ElementaryCaRule202 presets are well-formed', () {
    final m = F0962ElementaryCaRule202();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0962ElementaryCaRule202 metadata is consistent', () {
    final m = F0962ElementaryCaRule202();
    expect(m.metadata.id, m.id);
  });
}

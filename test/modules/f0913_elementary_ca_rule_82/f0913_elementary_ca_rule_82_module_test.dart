// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0913_elementary_ca_rule_82/f0913_elementary_ca_rule_82_module.dart';

void main() {
  test('F0913ElementaryCaRule82 instantiates', () {
    final m = F0913ElementaryCaRule82();
    expect(m.id, 'f0913_elementary_ca_rule_82');
    expect(m.shader, 'shaders/f0913_elementary_ca_rule_82_gpu.frag');
  });

  test('F0913ElementaryCaRule82 presets are well-formed', () {
    final m = F0913ElementaryCaRule82();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0913ElementaryCaRule82 metadata is consistent', () {
    final m = F0913ElementaryCaRule82();
    expect(m.metadata.id, m.id);
  });
}

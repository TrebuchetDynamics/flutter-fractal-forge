// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0893_elementary_ca_rule_28/f0893_elementary_ca_rule_28_module.dart';

void main() {
  test('F0893ElementaryCaRule28 instantiates', () {
    final m = F0893ElementaryCaRule28();
    expect(m.id, 'f0893_elementary_ca_rule_28');
    expect(m.shader, 'shaders/f0893_elementary_ca_rule_28_gpu.frag');
  });

  test('F0893ElementaryCaRule28 presets are well-formed', () {
    final m = F0893ElementaryCaRule28();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0893ElementaryCaRule28 metadata is consistent', () {
    final m = F0893ElementaryCaRule28();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0297_elementary_ca_rule_30/f0297_elementary_ca_rule_30_module.dart';

void main() {
  test('F0297ElementaryCaRule30 instantiates', () {
    final m = F0297ElementaryCaRule30();
    expect(m.id, 'f0297_elementary_ca_rule_30');
    expect(m.shader, 'shaders/f0297_elementary_ca_rule_30_gpu.frag');
  });

  test('F0297ElementaryCaRule30 presets are well-formed', () {
    final m = F0297ElementaryCaRule30();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0297ElementaryCaRule30 metadata is consistent', () {
    final m = F0297ElementaryCaRule30();
    expect(m.metadata.id, m.id);
  });
}

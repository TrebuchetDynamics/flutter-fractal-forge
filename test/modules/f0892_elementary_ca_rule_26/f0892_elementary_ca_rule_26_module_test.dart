// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0892_elementary_ca_rule_26/f0892_elementary_ca_rule_26_module.dart';

void main() {
  test('F0892ElementaryCaRule26 instantiates', () {
    final m = F0892ElementaryCaRule26();
    expect(m.id, 'f0892_elementary_ca_rule_26');
    expect(m.shader, 'shaders/f0892_elementary_ca_rule_26_gpu.frag');
  });

  test('F0892ElementaryCaRule26 presets are well-formed', () {
    final m = F0892ElementaryCaRule26();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0892ElementaryCaRule26 metadata is consistent', () {
    final m = F0892ElementaryCaRule26();
    expect(m.metadata.id, m.id);
  });
}

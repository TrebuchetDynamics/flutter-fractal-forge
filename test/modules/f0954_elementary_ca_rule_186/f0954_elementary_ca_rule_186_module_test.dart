// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0954_elementary_ca_rule_186/f0954_elementary_ca_rule_186_module.dart';

void main() {
  test('F0954ElementaryCaRule186 instantiates', () {
    final m = F0954ElementaryCaRule186();
    expect(m.id, 'f0954_elementary_ca_rule_186');
    expect(m.shader, 'shaders/f0954_elementary_ca_rule_186_gpu.frag');
  });

  test('F0954ElementaryCaRule186 presets are well-formed', () {
    final m = F0954ElementaryCaRule186();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0954ElementaryCaRule186 metadata is consistent', () {
    final m = F0954ElementaryCaRule186();
    expect(m.metadata.id, m.id);
  });
}

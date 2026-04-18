// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0928_elementary_ca_rule_128/f0928_elementary_ca_rule_128_module.dart';

void main() {
  test('F0928ElementaryCaRule128 instantiates', () {
    final m = F0928ElementaryCaRule128();
    expect(m.id, 'f0928_elementary_ca_rule_128');
    expect(m.shader, 'shaders/f0928_elementary_ca_rule_128_gpu.frag');
  });

  test('F0928ElementaryCaRule128 presets are well-formed', () {
    final m = F0928ElementaryCaRule128();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0928ElementaryCaRule128 metadata is consistent', () {
    final m = F0928ElementaryCaRule128();
    expect(m.metadata.id, m.id);
  });
}

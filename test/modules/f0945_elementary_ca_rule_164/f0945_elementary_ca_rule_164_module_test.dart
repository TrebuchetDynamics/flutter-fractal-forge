// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0945_elementary_ca_rule_164/f0945_elementary_ca_rule_164_module.dart';

void main() {
  test('F0945ElementaryCaRule164 instantiates', () {
    final m = F0945ElementaryCaRule164();
    expect(m.id, 'f0945_elementary_ca_rule_164');
    expect(m.shader, 'shaders/f0945_elementary_ca_rule_164_gpu.frag');
  });

  test('F0945ElementaryCaRule164 presets are well-formed', () {
    final m = F0945ElementaryCaRule164();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0945ElementaryCaRule164 metadata is consistent', () {
    final m = F0945ElementaryCaRule164();
    expect(m.metadata.id, m.id);
  });
}

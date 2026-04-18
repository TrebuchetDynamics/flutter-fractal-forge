// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0947_elementary_ca_rule_168/f0947_elementary_ca_rule_168_module.dart';

void main() {
  test('F0947ElementaryCaRule168 instantiates', () {
    final m = F0947ElementaryCaRule168();
    expect(m.id, 'f0947_elementary_ca_rule_168');
    expect(m.shader, 'shaders/f0947_elementary_ca_rule_168_gpu.frag');
  });

  test('F0947ElementaryCaRule168 presets are well-formed', () {
    final m = F0947ElementaryCaRule168();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0947ElementaryCaRule168 metadata is consistent', () {
    final m = F0947ElementaryCaRule168();
    expect(m.metadata.id, m.id);
  });
}

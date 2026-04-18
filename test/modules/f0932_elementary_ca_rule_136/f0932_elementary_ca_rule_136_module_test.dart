// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0932_elementary_ca_rule_136/f0932_elementary_ca_rule_136_module.dart';

void main() {
  test('F0932ElementaryCaRule136 instantiates', () {
    final m = F0932ElementaryCaRule136();
    expect(m.id, 'f0932_elementary_ca_rule_136');
    expect(m.shader, 'shaders/f0932_elementary_ca_rule_136_gpu.frag');
  });

  test('F0932ElementaryCaRule136 presets are well-formed', () {
    final m = F0932ElementaryCaRule136();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0932ElementaryCaRule136 metadata is consistent', () {
    final m = F0932ElementaryCaRule136();
    expect(m.metadata.id, m.id);
  });
}

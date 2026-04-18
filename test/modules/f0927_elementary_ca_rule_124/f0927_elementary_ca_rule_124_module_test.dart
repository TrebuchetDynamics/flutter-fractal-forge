// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0927_elementary_ca_rule_124/f0927_elementary_ca_rule_124_module.dart';

void main() {
  test('F0927ElementaryCaRule124 instantiates', () {
    final m = F0927ElementaryCaRule124();
    expect(m.id, 'f0927_elementary_ca_rule_124');
    expect(m.shader, 'shaders/f0927_elementary_ca_rule_124_gpu.frag');
  });

  test('F0927ElementaryCaRule124 presets are well-formed', () {
    final m = F0927ElementaryCaRule124();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0927ElementaryCaRule124 metadata is consistent', () {
    final m = F0927ElementaryCaRule124();
    expect(m.metadata.id, m.id);
  });
}

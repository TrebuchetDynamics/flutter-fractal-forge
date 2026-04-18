// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0956_elementary_ca_rule_190/f0956_elementary_ca_rule_190_module.dart';

void main() {
  test('F0956ElementaryCaRule190 instantiates', () {
    final m = F0956ElementaryCaRule190();
    expect(m.id, 'f0956_elementary_ca_rule_190');
    expect(m.shader, 'shaders/f0956_elementary_ca_rule_190_gpu.frag');
  });

  test('F0956ElementaryCaRule190 presets are well-formed', () {
    final m = F0956ElementaryCaRule190();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0956ElementaryCaRule190 metadata is consistent', () {
    final m = F0956ElementaryCaRule190();
    expect(m.metadata.id, m.id);
  });
}

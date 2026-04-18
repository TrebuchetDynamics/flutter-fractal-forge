// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0971_elementary_ca_rule_222/f0971_elementary_ca_rule_222_module.dart';

void main() {
  test('F0971ElementaryCaRule222 instantiates', () {
    final m = F0971ElementaryCaRule222();
    expect(m.id, 'f0971_elementary_ca_rule_222');
    expect(m.shader, 'shaders/f0971_elementary_ca_rule_222_gpu.frag');
  });

  test('F0971ElementaryCaRule222 presets are well-formed', () {
    final m = F0971ElementaryCaRule222();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0971ElementaryCaRule222 metadata is consistent', () {
    final m = F0971ElementaryCaRule222();
    expect(m.metadata.id, m.id);
  });
}

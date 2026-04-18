// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0974_elementary_ca_rule_232/f0974_elementary_ca_rule_232_module.dart';

void main() {
  test('F0974ElementaryCaRule232 instantiates', () {
    final m = F0974ElementaryCaRule232();
    expect(m.id, 'f0974_elementary_ca_rule_232');
    expect(m.shader, 'shaders/f0974_elementary_ca_rule_232_gpu.frag');
  });

  test('F0974ElementaryCaRule232 presets are well-formed', () {
    final m = F0974ElementaryCaRule232();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0974ElementaryCaRule232 metadata is consistent', () {
    final m = F0974ElementaryCaRule232();
    expect(m.metadata.id, m.id);
  });
}

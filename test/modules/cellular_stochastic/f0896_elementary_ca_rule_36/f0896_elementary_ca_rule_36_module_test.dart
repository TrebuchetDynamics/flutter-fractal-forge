// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0896_elementary_ca_rule_36/f0896_elementary_ca_rule_36_module.dart';

void main() {
  test('F0896ElementaryCaRule36 instantiates', () {
    final m = F0896ElementaryCaRule36();
    expect(m.id, 'f0896_elementary_ca_rule_36');
    expect(m.shader, 'shaders/f0896_elementary_ca_rule_36_gpu.frag');
  });

  test('F0896ElementaryCaRule36 presets are well-formed', () {
    final m = F0896ElementaryCaRule36();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0896ElementaryCaRule36 metadata is consistent', () {
    final m = F0896ElementaryCaRule36();
    expect(m.metadata.id, m.id);
  });
}

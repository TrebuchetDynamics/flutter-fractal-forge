// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0951_elementary_ca_rule_176/f0951_elementary_ca_rule_176_module.dart';

void main() {
  test('F0951ElementaryCaRule176 instantiates', () {
    final m = F0951ElementaryCaRule176();
    expect(m.id, 'f0951_elementary_ca_rule_176');
    expect(m.shader, 'shaders/f0951_elementary_ca_rule_176_gpu.frag');
  });

  test('F0951ElementaryCaRule176 presets are well-formed', () {
    final m = F0951ElementaryCaRule176();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0951ElementaryCaRule176 metadata is consistent', () {
    final m = F0951ElementaryCaRule176();
    expect(m.metadata.id, m.id);
  });
}

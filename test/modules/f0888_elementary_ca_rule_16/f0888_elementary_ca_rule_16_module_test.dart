// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0888_elementary_ca_rule_16/f0888_elementary_ca_rule_16_module.dart';

void main() {
  test('F0888ElementaryCaRule16 instantiates', () {
    final m = F0888ElementaryCaRule16();
    expect(m.id, 'f0888_elementary_ca_rule_16');
    expect(m.shader, 'shaders/f0888_elementary_ca_rule_16_gpu.frag');
  });

  test('F0888ElementaryCaRule16 presets are well-formed', () {
    final m = F0888ElementaryCaRule16();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0888ElementaryCaRule16 metadata is consistent', () {
    final m = F0888ElementaryCaRule16();
    expect(m.metadata.id, m.id);
  });
}

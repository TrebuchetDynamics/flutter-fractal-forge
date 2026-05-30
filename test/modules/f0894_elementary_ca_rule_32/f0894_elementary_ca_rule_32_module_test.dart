// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0894_elementary_ca_rule_32/f0894_elementary_ca_rule_32_module.dart';

void main() {
  test('F0894ElementaryCaRule32 instantiates', () {
    final m = F0894ElementaryCaRule32();
    expect(m.id, 'f0894_elementary_ca_rule_32');
    expect(m.shader, 'shaders/f0894_elementary_ca_rule_32_gpu.frag');
  });

  test('F0894ElementaryCaRule32 presets are well-formed', () {
    final m = F0894ElementaryCaRule32();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0894ElementaryCaRule32 metadata is consistent', () {
    final m = F0894ElementaryCaRule32();
    expect(m.metadata.id, m.id);
  });
}

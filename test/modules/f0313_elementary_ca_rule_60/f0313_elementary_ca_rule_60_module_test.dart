// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0313_elementary_ca_rule_60/f0313_elementary_ca_rule_60_module.dart';

void main() {
  test('F0313ElementaryCaRule60 instantiates', () {
    final m = F0313ElementaryCaRule60();
    expect(m.id, 'f0313_elementary_ca_rule_60');
    expect(m.shader, 'shaders/f0313_elementary_ca_rule_60_gpu.frag');
  });

  test('F0313ElementaryCaRule60 presets are well-formed', () {
    final m = F0313ElementaryCaRule60();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0313ElementaryCaRule60 metadata is consistent', () {
    final m = F0313ElementaryCaRule60();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0942_elementary_ca_rule_158/f0942_elementary_ca_rule_158_module.dart';

void main() {
  test('F0942ElementaryCaRule158 instantiates', () {
    final m = F0942ElementaryCaRule158();
    expect(m.id, 'f0942_elementary_ca_rule_158');
    expect(m.shader, 'shaders/f0942_elementary_ca_rule_158_gpu.frag');
  });

  test('F0942ElementaryCaRule158 presets are well-formed', () {
    final m = F0942ElementaryCaRule158();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0942ElementaryCaRule158 metadata is consistent', () {
    final m = F0942ElementaryCaRule158();
    expect(m.metadata.id, m.id);
  });
}

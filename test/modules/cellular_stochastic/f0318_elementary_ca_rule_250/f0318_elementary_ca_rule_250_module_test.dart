// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0318_elementary_ca_rule_250/f0318_elementary_ca_rule_250_module.dart';

void main() {
  test('F0318ElementaryCaRule250 instantiates', () {
    final m = F0318ElementaryCaRule250();
    expect(m.id, 'f0318_elementary_ca_rule_250');
    expect(m.shader, 'shaders/f0318_elementary_ca_rule_250_gpu.frag');
  });

  test('F0318ElementaryCaRule250 presets are well-formed', () {
    final m = F0318ElementaryCaRule250();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0318ElementaryCaRule250 metadata is consistent', () {
    final m = F0318ElementaryCaRule250();
    expect(m.metadata.id, m.id);
  });
}

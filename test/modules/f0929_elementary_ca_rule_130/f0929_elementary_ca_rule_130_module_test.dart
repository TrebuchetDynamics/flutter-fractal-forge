// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0929_elementary_ca_rule_130/f0929_elementary_ca_rule_130_module.dart';

void main() {
  test('F0929ElementaryCaRule130 instantiates', () {
    final m = F0929ElementaryCaRule130();
    expect(m.id, 'f0929_elementary_ca_rule_130');
    expect(m.shader, 'shaders/f0929_elementary_ca_rule_130_gpu.frag');
  });

  test('F0929ElementaryCaRule130 presets are well-formed', () {
    final m = F0929ElementaryCaRule130();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0929ElementaryCaRule130 metadata is consistent', () {
    final m = F0929ElementaryCaRule130();
    expect(m.metadata.id, m.id);
  });
}

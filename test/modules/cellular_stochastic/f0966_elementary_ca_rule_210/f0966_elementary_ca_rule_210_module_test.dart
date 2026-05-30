// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0966_elementary_ca_rule_210/f0966_elementary_ca_rule_210_module.dart';

void main() {
  test('F0966ElementaryCaRule210 instantiates', () {
    final m = F0966ElementaryCaRule210();
    expect(m.id, 'f0966_elementary_ca_rule_210');
    expect(m.shader, 'shaders/f0966_elementary_ca_rule_210_gpu.frag');
  });

  test('F0966ElementaryCaRule210 presets are well-formed', () {
    final m = F0966ElementaryCaRule210();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0966ElementaryCaRule210 metadata is consistent', () {
    final m = F0966ElementaryCaRule210();
    expect(m.metadata.id, m.id);
  });
}

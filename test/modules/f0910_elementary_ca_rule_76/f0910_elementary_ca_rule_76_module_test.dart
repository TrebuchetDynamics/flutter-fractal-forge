// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0910_elementary_ca_rule_76/f0910_elementary_ca_rule_76_module.dart';

void main() {
  test('F0910ElementaryCaRule76 instantiates', () {
    final m = F0910ElementaryCaRule76();
    expect(m.id, 'f0910_elementary_ca_rule_76');
    expect(m.shader, 'shaders/f0910_elementary_ca_rule_76_gpu.frag');
  });

  test('F0910ElementaryCaRule76 presets are well-formed', () {
    final m = F0910ElementaryCaRule76();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0910ElementaryCaRule76 metadata is consistent', () {
    final m = F0910ElementaryCaRule76();
    expect(m.metadata.id, m.id);
  });
}

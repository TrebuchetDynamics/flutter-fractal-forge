// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0978_elementary_ca_rule_246/f0978_elementary_ca_rule_246_module.dart';

void main() {
  test('F0978ElementaryCaRule246 instantiates', () {
    final m = F0978ElementaryCaRule246();
    expect(m.id, 'f0978_elementary_ca_rule_246');
    expect(m.shader, 'shaders/f0978_elementary_ca_rule_246_gpu.frag');
  });

  test('F0978ElementaryCaRule246 presets are well-formed', () {
    final m = F0978ElementaryCaRule246();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0978ElementaryCaRule246 metadata is consistent', () {
    final m = F0978ElementaryCaRule246();
    expect(m.metadata.id, m.id);
  });
}

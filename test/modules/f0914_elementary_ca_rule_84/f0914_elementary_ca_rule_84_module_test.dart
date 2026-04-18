// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0914_elementary_ca_rule_84/f0914_elementary_ca_rule_84_module.dart';

void main() {
  test('F0914ElementaryCaRule84 instantiates', () {
    final m = F0914ElementaryCaRule84();
    expect(m.id, 'f0914_elementary_ca_rule_84');
    expect(m.shader, 'shaders/f0914_elementary_ca_rule_84_gpu.frag');
  });

  test('F0914ElementaryCaRule84 presets are well-formed', () {
    final m = F0914ElementaryCaRule84();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0914ElementaryCaRule84 metadata is consistent', () {
    final m = F0914ElementaryCaRule84();
    expect(m.metadata.id, m.id);
  });
}

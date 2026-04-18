// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0949_elementary_ca_rule_172/f0949_elementary_ca_rule_172_module.dart';

void main() {
  test('F0949ElementaryCaRule172 instantiates', () {
    final m = F0949ElementaryCaRule172();
    expect(m.id, 'f0949_elementary_ca_rule_172');
    expect(m.shader, 'shaders/f0949_elementary_ca_rule_172_gpu.frag');
  });

  test('F0949ElementaryCaRule172 presets are well-formed', () {
    final m = F0949ElementaryCaRule172();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0949ElementaryCaRule172 metadata is consistent', () {
    final m = F0949ElementaryCaRule172();
    expect(m.metadata.id, m.id);
  });
}

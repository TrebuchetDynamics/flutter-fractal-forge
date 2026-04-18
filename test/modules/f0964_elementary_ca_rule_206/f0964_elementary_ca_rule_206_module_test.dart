// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0964_elementary_ca_rule_206/f0964_elementary_ca_rule_206_module.dart';

void main() {
  test('F0964ElementaryCaRule206 instantiates', () {
    final m = F0964ElementaryCaRule206();
    expect(m.id, 'f0964_elementary_ca_rule_206');
    expect(m.shader, 'shaders/f0964_elementary_ca_rule_206_gpu.frag');
  });

  test('F0964ElementaryCaRule206 presets are well-formed', () {
    final m = F0964ElementaryCaRule206();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0964ElementaryCaRule206 metadata is consistent', () {
    final m = F0964ElementaryCaRule206();
    expect(m.metadata.id, m.id);
  });
}

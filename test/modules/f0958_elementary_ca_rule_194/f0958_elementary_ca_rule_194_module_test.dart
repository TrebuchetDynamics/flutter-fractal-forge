// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0958_elementary_ca_rule_194/f0958_elementary_ca_rule_194_module.dart';

void main() {
  test('F0958ElementaryCaRule194 instantiates', () {
    final m = F0958ElementaryCaRule194();
    expect(m.id, 'f0958_elementary_ca_rule_194');
    expect(m.shader, 'shaders/f0958_elementary_ca_rule_194_gpu.frag');
  });

  test('F0958ElementaryCaRule194 presets are well-formed', () {
    final m = F0958ElementaryCaRule194();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0958ElementaryCaRule194 metadata is consistent', () {
    final m = F0958ElementaryCaRule194();
    expect(m.metadata.id, m.id);
  });
}

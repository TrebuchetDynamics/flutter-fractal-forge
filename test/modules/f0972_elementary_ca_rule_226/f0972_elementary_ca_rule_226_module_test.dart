// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0972_elementary_ca_rule_226/f0972_elementary_ca_rule_226_module.dart';

void main() {
  test('F0972ElementaryCaRule226 instantiates', () {
    final m = F0972ElementaryCaRule226();
    expect(m.id, 'f0972_elementary_ca_rule_226');
    expect(m.shader, 'shaders/f0972_elementary_ca_rule_226_gpu.frag');
  });

  test('F0972ElementaryCaRule226 presets are well-formed', () {
    final m = F0972ElementaryCaRule226();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0972ElementaryCaRule226 metadata is consistent', () {
    final m = F0972ElementaryCaRule226();
    expect(m.metadata.id, m.id);
  });
}

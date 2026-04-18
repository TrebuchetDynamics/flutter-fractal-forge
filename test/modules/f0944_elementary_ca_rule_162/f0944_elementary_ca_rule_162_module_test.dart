// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0944_elementary_ca_rule_162/f0944_elementary_ca_rule_162_module.dart';

void main() {
  test('F0944ElementaryCaRule162 instantiates', () {
    final m = F0944ElementaryCaRule162();
    expect(m.id, 'f0944_elementary_ca_rule_162');
    expect(m.shader, 'shaders/f0944_elementary_ca_rule_162_gpu.frag');
  });

  test('F0944ElementaryCaRule162 presets are well-formed', () {
    final m = F0944ElementaryCaRule162();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0944ElementaryCaRule162 metadata is consistent', () {
    final m = F0944ElementaryCaRule162();
    expect(m.metadata.id, m.id);
  });
}

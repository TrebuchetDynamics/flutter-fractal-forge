// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0308_elementary_ca_rule_150/f0308_elementary_ca_rule_150_module.dart';

void main() {
  test('F0308ElementaryCaRule150 instantiates', () {
    final m = F0308ElementaryCaRule150();
    expect(m.id, 'f0308_elementary_ca_rule_150');
    expect(m.shader, 'shaders/f0308_elementary_ca_rule_150_gpu.frag');
  });

  test('F0308ElementaryCaRule150 presets are well-formed', () {
    final m = F0308ElementaryCaRule150();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0308ElementaryCaRule150 metadata is consistent', () {
    final m = F0308ElementaryCaRule150();
    expect(m.metadata.id, m.id);
  });
}

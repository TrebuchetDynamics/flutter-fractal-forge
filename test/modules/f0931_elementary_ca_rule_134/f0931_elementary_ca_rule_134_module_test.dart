// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0931_elementary_ca_rule_134/f0931_elementary_ca_rule_134_module.dart';

void main() {
  test('F0931ElementaryCaRule134 instantiates', () {
    final m = F0931ElementaryCaRule134();
    expect(m.id, 'f0931_elementary_ca_rule_134');
    expect(m.shader, 'shaders/f0931_elementary_ca_rule_134_gpu.frag');
  });

  test('F0931ElementaryCaRule134 presets are well-formed', () {
    final m = F0931ElementaryCaRule134();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0931ElementaryCaRule134 metadata is consistent', () {
    final m = F0931ElementaryCaRule134();
    expect(m.metadata.id, m.id);
  });
}

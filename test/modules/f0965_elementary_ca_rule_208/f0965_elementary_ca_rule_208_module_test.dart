// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0965_elementary_ca_rule_208/f0965_elementary_ca_rule_208_module.dart';

void main() {
  test('F0965ElementaryCaRule208 instantiates', () {
    final m = F0965ElementaryCaRule208();
    expect(m.id, 'f0965_elementary_ca_rule_208');
    expect(m.shader, 'shaders/f0965_elementary_ca_rule_208_gpu.frag');
  });

  test('F0965ElementaryCaRule208 presets are well-formed', () {
    final m = F0965ElementaryCaRule208();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0965ElementaryCaRule208 metadata is consistent', () {
    final m = F0965ElementaryCaRule208();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0884_elementary_ca_rule_8/f0884_elementary_ca_rule_8_module.dart';

void main() {
  test('F0884ElementaryCaRule8 instantiates', () {
    final m = F0884ElementaryCaRule8();
    expect(m.id, 'f0884_elementary_ca_rule_8');
    expect(m.shader, 'shaders/f0884_elementary_ca_rule_8_gpu.frag');
  });

  test('F0884ElementaryCaRule8 presets are well-formed', () {
    final m = F0884ElementaryCaRule8();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0884ElementaryCaRule8 metadata is consistent', () {
    final m = F0884ElementaryCaRule8();
    expect(m.metadata.id, m.id);
  });
}

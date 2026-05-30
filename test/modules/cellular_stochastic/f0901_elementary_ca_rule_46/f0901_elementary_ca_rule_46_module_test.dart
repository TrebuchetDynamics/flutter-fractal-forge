// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0901_elementary_ca_rule_46/f0901_elementary_ca_rule_46_module.dart';

void main() {
  test('F0901ElementaryCaRule46 instantiates', () {
    final m = F0901ElementaryCaRule46();
    expect(m.id, 'f0901_elementary_ca_rule_46');
    expect(m.shader, 'shaders/f0901_elementary_ca_rule_46_gpu.frag');
  });

  test('F0901ElementaryCaRule46 presets are well-formed', () {
    final m = F0901ElementaryCaRule46();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0901ElementaryCaRule46 metadata is consistent', () {
    final m = F0901ElementaryCaRule46();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0943_elementary_ca_rule_160/f0943_elementary_ca_rule_160_module.dart';

void main() {
  test('F0943ElementaryCaRule160 instantiates', () {
    final m = F0943ElementaryCaRule160();
    expect(m.id, 'f0943_elementary_ca_rule_160');
    expect(m.shader, 'shaders/f0943_elementary_ca_rule_160_gpu.frag');
  });

  test('F0943ElementaryCaRule160 presets are well-formed', () {
    final m = F0943ElementaryCaRule160();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0943ElementaryCaRule160 metadata is consistent', () {
    final m = F0943ElementaryCaRule160();
    expect(m.metadata.id, m.id);
  });
}

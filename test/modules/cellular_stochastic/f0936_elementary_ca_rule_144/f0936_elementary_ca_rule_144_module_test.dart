// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0936_elementary_ca_rule_144/f0936_elementary_ca_rule_144_module.dart';

void main() {
  test('F0936ElementaryCaRule144 instantiates', () {
    final m = F0936ElementaryCaRule144();
    expect(m.id, 'f0936_elementary_ca_rule_144');
    expect(m.shader, 'shaders/f0936_elementary_ca_rule_144_gpu.frag');
  });

  test('F0936ElementaryCaRule144 presets are well-formed', () {
    final m = F0936ElementaryCaRule144();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0936ElementaryCaRule144 metadata is consistent', () {
    final m = F0936ElementaryCaRule144();
    expect(m.metadata.id, m.id);
  });
}

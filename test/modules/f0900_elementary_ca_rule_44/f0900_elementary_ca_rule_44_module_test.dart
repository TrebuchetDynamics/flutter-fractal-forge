// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0900_elementary_ca_rule_44/f0900_elementary_ca_rule_44_module.dart';

void main() {
  test('F0900ElementaryCaRule44 instantiates', () {
    final m = F0900ElementaryCaRule44();
    expect(m.id, 'f0900_elementary_ca_rule_44');
    expect(m.shader, 'shaders/f0900_elementary_ca_rule_44_gpu.frag');
  });

  test('F0900ElementaryCaRule44 presets are well-formed', () {
    final m = F0900ElementaryCaRule44();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0900ElementaryCaRule44 metadata is consistent', () {
    final m = F0900ElementaryCaRule44();
    expect(m.metadata.id, m.id);
  });
}

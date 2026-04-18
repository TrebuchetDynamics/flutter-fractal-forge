// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0940_elementary_ca_rule_154/f0940_elementary_ca_rule_154_module.dart';

void main() {
  test('F0940ElementaryCaRule154 instantiates', () {
    final m = F0940ElementaryCaRule154();
    expect(m.id, 'f0940_elementary_ca_rule_154');
    expect(m.shader, 'shaders/f0940_elementary_ca_rule_154_gpu.frag');
  });

  test('F0940ElementaryCaRule154 presets are well-formed', () {
    final m = F0940ElementaryCaRule154();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0940ElementaryCaRule154 metadata is consistent', () {
    final m = F0940ElementaryCaRule154();
    expect(m.metadata.id, m.id);
  });
}

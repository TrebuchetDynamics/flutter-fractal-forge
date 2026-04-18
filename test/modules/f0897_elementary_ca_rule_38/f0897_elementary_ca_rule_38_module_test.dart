// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0897_elementary_ca_rule_38/f0897_elementary_ca_rule_38_module.dart';

void main() {
  test('F0897ElementaryCaRule38 instantiates', () {
    final m = F0897ElementaryCaRule38();
    expect(m.id, 'f0897_elementary_ca_rule_38');
    expect(m.shader, 'shaders/f0897_elementary_ca_rule_38_gpu.frag');
  });

  test('F0897ElementaryCaRule38 presets are well-formed', () {
    final m = F0897ElementaryCaRule38();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0897ElementaryCaRule38 metadata is consistent', () {
    final m = F0897ElementaryCaRule38();
    expect(m.metadata.id, m.id);
  });
}

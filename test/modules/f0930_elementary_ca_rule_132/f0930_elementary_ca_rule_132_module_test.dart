// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0930_elementary_ca_rule_132/f0930_elementary_ca_rule_132_module.dart';

void main() {
  test('F0930ElementaryCaRule132 instantiates', () {
    final m = F0930ElementaryCaRule132();
    expect(m.id, 'f0930_elementary_ca_rule_132');
    expect(m.shader, 'shaders/f0930_elementary_ca_rule_132_gpu.frag');
  });

  test('F0930ElementaryCaRule132 presets are well-formed', () {
    final m = F0930ElementaryCaRule132();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0930ElementaryCaRule132 metadata is consistent', () {
    final m = F0930ElementaryCaRule132();
    expect(m.metadata.id, m.id);
  });
}

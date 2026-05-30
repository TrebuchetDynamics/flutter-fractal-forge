// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0976_elementary_ca_rule_238/f0976_elementary_ca_rule_238_module.dart';

void main() {
  test('F0976ElementaryCaRule238 instantiates', () {
    final m = F0976ElementaryCaRule238();
    expect(m.id, 'f0976_elementary_ca_rule_238');
    expect(m.shader, 'shaders/f0976_elementary_ca_rule_238_gpu.frag');
  });

  test('F0976ElementaryCaRule238 presets are well-formed', () {
    final m = F0976ElementaryCaRule238();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0976ElementaryCaRule238 metadata is consistent', () {
    final m = F0976ElementaryCaRule238();
    expect(m.metadata.id, m.id);
  });
}

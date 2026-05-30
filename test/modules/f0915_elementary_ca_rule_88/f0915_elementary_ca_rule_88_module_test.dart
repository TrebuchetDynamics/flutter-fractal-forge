// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0915_elementary_ca_rule_88/f0915_elementary_ca_rule_88_module.dart';

void main() {
  test('F0915ElementaryCaRule88 instantiates', () {
    final m = F0915ElementaryCaRule88();
    expect(m.id, 'f0915_elementary_ca_rule_88');
    expect(m.shader, 'shaders/f0915_elementary_ca_rule_88_gpu.frag');
  });

  test('F0915ElementaryCaRule88 presets are well-formed', () {
    final m = F0915ElementaryCaRule88();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0915ElementaryCaRule88 metadata is consistent', () {
    final m = F0915ElementaryCaRule88();
    expect(m.metadata.id, m.id);
  });
}

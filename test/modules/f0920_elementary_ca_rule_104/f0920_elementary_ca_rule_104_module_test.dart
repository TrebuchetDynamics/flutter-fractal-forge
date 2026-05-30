// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0920_elementary_ca_rule_104/f0920_elementary_ca_rule_104_module.dart';

void main() {
  test('F0920ElementaryCaRule104 instantiates', () {
    final m = F0920ElementaryCaRule104();
    expect(m.id, 'f0920_elementary_ca_rule_104');
    expect(m.shader, 'shaders/f0920_elementary_ca_rule_104_gpu.frag');
  });

  test('F0920ElementaryCaRule104 presets are well-formed', () {
    final m = F0920ElementaryCaRule104();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0920ElementaryCaRule104 metadata is consistent', () {
    final m = F0920ElementaryCaRule104();
    expect(m.metadata.id, m.id);
  });
}

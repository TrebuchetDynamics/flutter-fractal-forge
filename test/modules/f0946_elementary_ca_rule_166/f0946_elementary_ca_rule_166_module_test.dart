// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0946_elementary_ca_rule_166/f0946_elementary_ca_rule_166_module.dart';

void main() {
  test('F0946ElementaryCaRule166 instantiates', () {
    final m = F0946ElementaryCaRule166();
    expect(m.id, 'f0946_elementary_ca_rule_166');
    expect(m.shader, 'shaders/f0946_elementary_ca_rule_166_gpu.frag');
  });

  test('F0946ElementaryCaRule166 presets are well-formed', () {
    final m = F0946ElementaryCaRule166();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0946ElementaryCaRule166 metadata is consistent', () {
    final m = F0946ElementaryCaRule166();
    expect(m.metadata.id, m.id);
  });
}

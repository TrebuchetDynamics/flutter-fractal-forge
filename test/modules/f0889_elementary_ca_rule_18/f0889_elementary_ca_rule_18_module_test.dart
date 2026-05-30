// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0889_elementary_ca_rule_18/f0889_elementary_ca_rule_18_module.dart';

void main() {
  test('F0889ElementaryCaRule18 instantiates', () {
    final m = F0889ElementaryCaRule18();
    expect(m.id, 'f0889_elementary_ca_rule_18');
    expect(m.shader, 'shaders/f0889_elementary_ca_rule_18_gpu.frag');
  });

  test('F0889ElementaryCaRule18 presets are well-formed', () {
    final m = F0889ElementaryCaRule18();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0889ElementaryCaRule18 metadata is consistent', () {
    final m = F0889ElementaryCaRule18();
    expect(m.metadata.id, m.id);
  });
}

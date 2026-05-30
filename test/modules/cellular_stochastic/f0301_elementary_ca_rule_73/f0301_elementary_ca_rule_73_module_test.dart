// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0301_elementary_ca_rule_73/f0301_elementary_ca_rule_73_module.dart';

void main() {
  test('F0301ElementaryCaRule73 instantiates', () {
    final m = F0301ElementaryCaRule73();
    expect(m.id, 'f0301_elementary_ca_rule_73');
    expect(m.shader, 'shaders/f0301_elementary_ca_rule_73_gpu.frag');
  });

  test('F0301ElementaryCaRule73 presets are well-formed', () {
    final m = F0301ElementaryCaRule73();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0301ElementaryCaRule73 metadata is consistent', () {
    final m = F0301ElementaryCaRule73();
    expect(m.metadata.id, m.id);
  });
}

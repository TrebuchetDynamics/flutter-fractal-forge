// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0919_elementary_ca_rule_100/f0919_elementary_ca_rule_100_module.dart';

void main() {
  test('F0919ElementaryCaRule100 instantiates', () {
    final m = F0919ElementaryCaRule100();
    expect(m.id, 'f0919_elementary_ca_rule_100');
    expect(m.shader, 'shaders/f0919_elementary_ca_rule_100_gpu.frag');
  });

  test('F0919ElementaryCaRule100 presets are well-formed', () {
    final m = F0919ElementaryCaRule100();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0919ElementaryCaRule100 metadata is consistent', () {
    final m = F0919ElementaryCaRule100();
    expect(m.metadata.id, m.id);
  });
}

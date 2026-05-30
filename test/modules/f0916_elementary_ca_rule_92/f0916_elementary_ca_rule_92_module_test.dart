// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0916_elementary_ca_rule_92/f0916_elementary_ca_rule_92_module.dart';

void main() {
  test('F0916ElementaryCaRule92 instantiates', () {
    final m = F0916ElementaryCaRule92();
    expect(m.id, 'f0916_elementary_ca_rule_92');
    expect(m.shader, 'shaders/f0916_elementary_ca_rule_92_gpu.frag');
  });

  test('F0916ElementaryCaRule92 presets are well-formed', () {
    final m = F0916ElementaryCaRule92();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0916ElementaryCaRule92 metadata is consistent', () {
    final m = F0916ElementaryCaRule92();
    expect(m.metadata.id, m.id);
  });
}

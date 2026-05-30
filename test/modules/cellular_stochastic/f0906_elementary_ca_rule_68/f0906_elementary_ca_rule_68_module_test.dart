// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0906_elementary_ca_rule_68/f0906_elementary_ca_rule_68_module.dart';

void main() {
  test('F0906ElementaryCaRule68 instantiates', () {
    final m = F0906ElementaryCaRule68();
    expect(m.id, 'f0906_elementary_ca_rule_68');
    expect(m.shader, 'shaders/f0906_elementary_ca_rule_68_gpu.frag');
  });

  test('F0906ElementaryCaRule68 presets are well-formed', () {
    final m = F0906ElementaryCaRule68();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0906ElementaryCaRule68 metadata is consistent', () {
    final m = F0906ElementaryCaRule68();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0955_elementary_ca_rule_188/f0955_elementary_ca_rule_188_module.dart';

void main() {
  test('F0955ElementaryCaRule188 instantiates', () {
    final m = F0955ElementaryCaRule188();
    expect(m.id, 'f0955_elementary_ca_rule_188');
    expect(m.shader, 'shaders/f0955_elementary_ca_rule_188_gpu.frag');
  });

  test('F0955ElementaryCaRule188 presets are well-formed', () {
    final m = F0955ElementaryCaRule188();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0955ElementaryCaRule188 metadata is consistent', () {
    final m = F0955ElementaryCaRule188();
    expect(m.metadata.id, m.id);
  });
}

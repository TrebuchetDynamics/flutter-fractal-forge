// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0933_elementary_ca_rule_138/f0933_elementary_ca_rule_138_module.dart';

void main() {
  test('F0933ElementaryCaRule138 instantiates', () {
    final m = F0933ElementaryCaRule138();
    expect(m.id, 'f0933_elementary_ca_rule_138');
    expect(m.shader, 'shaders/f0933_elementary_ca_rule_138_gpu.frag');
  });

  test('F0933ElementaryCaRule138 presets are well-formed', () {
    final m = F0933ElementaryCaRule138();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0933ElementaryCaRule138 metadata is consistent', () {
    final m = F0933ElementaryCaRule138();
    expect(m.metadata.id, m.id);
  });
}

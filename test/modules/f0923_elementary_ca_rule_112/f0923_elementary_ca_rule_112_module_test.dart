// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0923_elementary_ca_rule_112/f0923_elementary_ca_rule_112_module.dart';

void main() {
  test('F0923ElementaryCaRule112 instantiates', () {
    final m = F0923ElementaryCaRule112();
    expect(m.id, 'f0923_elementary_ca_rule_112');
    expect(m.shader, 'shaders/f0923_elementary_ca_rule_112_gpu.frag');
  });

  test('F0923ElementaryCaRule112 presets are well-formed', () {
    final m = F0923ElementaryCaRule112();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0923ElementaryCaRule112 metadata is consistent', () {
    final m = F0923ElementaryCaRule112();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0950_elementary_ca_rule_174/f0950_elementary_ca_rule_174_module.dart';

void main() {
  test('F0950ElementaryCaRule174 instantiates', () {
    final m = F0950ElementaryCaRule174();
    expect(m.id, 'f0950_elementary_ca_rule_174');
    expect(m.shader, 'shaders/f0950_elementary_ca_rule_174_gpu.frag');
  });

  test('F0950ElementaryCaRule174 presets are well-formed', () {
    final m = F0950ElementaryCaRule174();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0950ElementaryCaRule174 metadata is consistent', () {
    final m = F0950ElementaryCaRule174();
    expect(m.metadata.id, m.id);
  });
}

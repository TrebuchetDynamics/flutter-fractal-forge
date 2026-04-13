// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0298_elementary_ca_rule_45/f0298_elementary_ca_rule_45_module.dart';

void main() {
  test('F0298ElementaryCaRule45 instantiates', () {
    final m = F0298ElementaryCaRule45();
    expect(m.id, 'f0298_elementary_ca_rule_45');
    expect(m.shader, 'shaders/f0298_elementary_ca_rule_45_gpu.frag');
  });

  test('F0298ElementaryCaRule45 presets are well-formed', () {
    final m = F0298ElementaryCaRule45();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0298ElementaryCaRule45 metadata is consistent', () {
    final m = F0298ElementaryCaRule45();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0902_elementary_ca_rule_56/f0902_elementary_ca_rule_56_module.dart';

void main() {
  test('F0902ElementaryCaRule56 instantiates', () {
    final m = F0902ElementaryCaRule56();
    expect(m.id, 'f0902_elementary_ca_rule_56');
    expect(m.shader, 'shaders/f0902_elementary_ca_rule_56_gpu.frag');
  });

  test('F0902ElementaryCaRule56 presets are well-formed', () {
    final m = F0902ElementaryCaRule56();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0902ElementaryCaRule56 metadata is consistent', () {
    final m = F0902ElementaryCaRule56();
    expect(m.metadata.id, m.id);
  });
}

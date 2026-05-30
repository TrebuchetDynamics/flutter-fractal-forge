// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0904_elementary_ca_rule_64/f0904_elementary_ca_rule_64_module.dart';

void main() {
  test('F0904ElementaryCaRule64 instantiates', () {
    final m = F0904ElementaryCaRule64();
    expect(m.id, 'f0904_elementary_ca_rule_64');
    expect(m.shader, 'shaders/f0904_elementary_ca_rule_64_gpu.frag');
  });

  test('F0904ElementaryCaRule64 presets are well-formed', () {
    final m = F0904ElementaryCaRule64();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0904ElementaryCaRule64 metadata is consistent', () {
    final m = F0904ElementaryCaRule64();
    expect(m.metadata.id, m.id);
  });
}

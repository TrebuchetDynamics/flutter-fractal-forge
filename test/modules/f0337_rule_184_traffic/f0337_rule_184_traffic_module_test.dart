// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0337_rule_184_traffic/f0337_rule_184_traffic_module.dart';

void main() {
  test('F0337Rule184Traffic instantiates', () {
    final m = F0337Rule184Traffic();
    expect(m.id, 'f0337_rule_184_traffic');
    expect(m.shader, 'shaders/f0337_rule_184_traffic_gpu.frag');
  });

  test('F0337Rule184Traffic presets are well-formed', () {
    final m = F0337Rule184Traffic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0337Rule184Traffic metadata is consistent', () {
    final m = F0337Rule184Traffic();
    expect(m.metadata.id, m.id);
  });
}

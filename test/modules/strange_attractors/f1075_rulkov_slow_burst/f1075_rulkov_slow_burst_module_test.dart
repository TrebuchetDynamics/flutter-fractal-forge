// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1075_rulkov_slow_burst/f1075_rulkov_slow_burst_module.dart';

void main() {
  test('F1075RulkovSlowBurst instantiates', () {
    final m = F1075RulkovSlowBurst();
    expect(m.id, 'f1075_rulkov_slow_burst');
    expect(m.shader, 'shaders/f1075_rulkov_slow_burst_gpu.frag');
  });

  test('F1075RulkovSlowBurst presets are well-formed', () {
    final m = F1075RulkovSlowBurst();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1075RulkovSlowBurst metadata is consistent', () {
    final m = F1075RulkovSlowBurst();
    expect(m.metadata.id, m.id);
  });
}

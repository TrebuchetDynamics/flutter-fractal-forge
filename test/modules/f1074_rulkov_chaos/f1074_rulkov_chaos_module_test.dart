// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1074_rulkov_chaos/f1074_rulkov_chaos_module.dart';

void main() {
  test('F1074RulkovChaos instantiates', () {
    final m = F1074RulkovChaos();
    expect(m.id, 'f1074_rulkov_chaos');
    expect(m.shader, 'shaders/f1074_rulkov_chaos_gpu.frag');
  });

  test('F1074RulkovChaos presets are well-formed', () {
    final m = F1074RulkovChaos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1074RulkovChaos metadata is consistent', () {
    final m = F1074RulkovChaos();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1073_rulkov_silent/f1073_rulkov_silent_module.dart';

void main() {
  test('F1073RulkovSilent instantiates', () {
    final m = F1073RulkovSilent();
    expect(m.id, 'f1073_rulkov_silent');
    expect(m.shader, 'shaders/f1073_rulkov_silent_gpu.frag');
  });

  test('F1073RulkovSilent presets are well-formed', () {
    final m = F1073RulkovSilent();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1073RulkovSilent metadata is consistent', () {
    final m = F1073RulkovSilent();
    expect(m.metadata.id, m.id);
  });
}

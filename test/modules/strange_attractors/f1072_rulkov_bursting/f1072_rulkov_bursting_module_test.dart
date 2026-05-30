// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1072_rulkov_bursting/f1072_rulkov_bursting_module.dart';

void main() {
  test('F1072RulkovBursting instantiates', () {
    final m = F1072RulkovBursting();
    expect(m.id, 'f1072_rulkov_bursting');
    expect(m.shader, 'shaders/f1072_rulkov_bursting_gpu.frag');
  });

  test('F1072RulkovBursting presets are well-formed', () {
    final m = F1072RulkovBursting();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1072RulkovBursting metadata is consistent', () {
    final m = F1072RulkovBursting();
    expect(m.metadata.id, m.id);
  });
}

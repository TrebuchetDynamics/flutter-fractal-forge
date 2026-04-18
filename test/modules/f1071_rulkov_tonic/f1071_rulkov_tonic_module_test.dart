// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1071_rulkov_tonic/f1071_rulkov_tonic_module.dart';

void main() {
  test('F1071RulkovTonic instantiates', () {
    final m = F1071RulkovTonic();
    expect(m.id, 'f1071_rulkov_tonic');
    expect(m.shader, 'shaders/f1071_rulkov_tonic_gpu.frag');
  });

  test('F1071RulkovTonic presets are well-formed', () {
    final m = F1071RulkovTonic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1071RulkovTonic metadata is consistent', () {
    final m = F1071RulkovTonic();
    expect(m.metadata.id, m.id);
  });
}

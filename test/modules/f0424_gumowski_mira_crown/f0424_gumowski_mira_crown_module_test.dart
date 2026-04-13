// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0424_gumowski_mira_crown/f0424_gumowski_mira_crown_module.dart';

void main() {
  test('F0424GumowskiMiraCrown instantiates', () {
    final m = F0424GumowskiMiraCrown();
    expect(m.id, 'f0424_gumowski_mira_crown');
    expect(m.shader, 'shaders/f0424_gumowski_mira_crown_gpu.frag');
  });

  test('F0424GumowskiMiraCrown presets are well-formed', () {
    final m = F0424GumowskiMiraCrown();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0424GumowskiMiraCrown metadata is consistent', () {
    final m = F0424GumowskiMiraCrown();
    expect(m.metadata.id, m.id);
  });
}

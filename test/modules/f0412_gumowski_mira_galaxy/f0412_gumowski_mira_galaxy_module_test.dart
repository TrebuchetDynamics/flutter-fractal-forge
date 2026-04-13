// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0412_gumowski_mira_galaxy/f0412_gumowski_mira_galaxy_module.dart';

void main() {
  test('F0412GumowskiMiraGalaxy instantiates', () {
    final m = F0412GumowskiMiraGalaxy();
    expect(m.id, 'f0412_gumowski_mira_galaxy');
    expect(m.shader, 'shaders/f0412_gumowski_mira_galaxy_gpu.frag');
  });

  test('F0412GumowskiMiraGalaxy presets are well-formed', () {
    final m = F0412GumowskiMiraGalaxy();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0412GumowskiMiraGalaxy metadata is consistent', () {
    final m = F0412GumowskiMiraGalaxy();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0422_gumowski_mira_sea_urchin/f0422_gumowski_mira_sea_urchin_module.dart';

void main() {
  test('F0422GumowskiMiraSeaUrchin instantiates', () {
    final m = F0422GumowskiMiraSeaUrchin();
    expect(m.id, 'f0422_gumowski_mira_sea_urchin');
    expect(m.shader, 'shaders/f0422_gumowski_mira_sea_urchin_gpu.frag');
  });

  test('F0422GumowskiMiraSeaUrchin presets are well-formed', () {
    final m = F0422GumowskiMiraSeaUrchin();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0422GumowskiMiraSeaUrchin metadata is consistent', () {
    final m = F0422GumowskiMiraSeaUrchin();
    expect(m.metadata.id, m.id);
  });
}

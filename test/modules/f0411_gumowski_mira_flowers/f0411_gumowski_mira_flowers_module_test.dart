// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0411_gumowski_mira_flowers/f0411_gumowski_mira_flowers_module.dart';

void main() {
  test('F0411GumowskiMiraFlowers instantiates', () {
    final m = F0411GumowskiMiraFlowers();
    expect(m.id, 'f0411_gumowski_mira_flowers');
    expect(m.shader, 'shaders/f0411_gumowski_mira_flowers_gpu.frag');
  });

  test('F0411GumowskiMiraFlowers presets are well-formed', () {
    final m = F0411GumowskiMiraFlowers();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0411GumowskiMiraFlowers metadata is consistent', () {
    final m = F0411GumowskiMiraFlowers();
    expect(m.metadata.id, m.id);
  });
}

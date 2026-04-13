// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0413_gumowski_mira_jellyfish/f0413_gumowski_mira_jellyfish_module.dart';

void main() {
  test('F0413GumowskiMiraJellyfish instantiates', () {
    final m = F0413GumowskiMiraJellyfish();
    expect(m.id, 'f0413_gumowski_mira_jellyfish');
    expect(m.shader, 'shaders/f0413_gumowski_mira_jellyfish_gpu.frag');
  });

  test('F0413GumowskiMiraJellyfish presets are well-formed', () {
    final m = F0413GumowskiMiraJellyfish();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0413GumowskiMiraJellyfish metadata is consistent', () {
    final m = F0413GumowskiMiraJellyfish();
    expect(m.metadata.id, m.id);
  });
}

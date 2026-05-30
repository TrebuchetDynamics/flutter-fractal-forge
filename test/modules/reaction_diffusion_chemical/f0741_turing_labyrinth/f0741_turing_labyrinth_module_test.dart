// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0741_turing_labyrinth/f0741_turing_labyrinth_module.dart';

void main() {
  test('F0741TuringLabyrinth instantiates', () {
    final m = F0741TuringLabyrinth();
    expect(m.id, 'f0741_turing_labyrinth');
    expect(m.shader, 'shaders/f0741_turing_labyrinth_gpu.frag');
  });

  test('F0741TuringLabyrinth presets are well-formed', () {
    final m = F0741TuringLabyrinth();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0741TuringLabyrinth metadata is consistent', () {
    final m = F0741TuringLabyrinth();
    expect(m.metadata.id, m.id);
  });
}

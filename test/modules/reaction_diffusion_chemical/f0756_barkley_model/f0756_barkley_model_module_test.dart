// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0756_barkley_model/f0756_barkley_model_module.dart';

void main() {
  test('F0756BarkleyModel instantiates', () {
    final m = F0756BarkleyModel();
    expect(m.id, 'f0756_barkley_model');
    expect(m.shader, 'shaders/f0756_barkley_model_gpu.frag');
  });

  test('F0756BarkleyModel presets are well-formed', () {
    final m = F0756BarkleyModel();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0756BarkleyModel metadata is consistent', () {
    final m = F0756BarkleyModel();
    expect(m.metadata.id, m.id);
  });
}

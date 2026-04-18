// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0752_schnakenberg_model/f0752_schnakenberg_model_module.dart';

void main() {
  test('F0752SchnakenbergModel instantiates', () {
    final m = F0752SchnakenbergModel();
    expect(m.id, 'f0752_schnakenberg_model');
    expect(m.shader, 'shaders/f0752_schnakenberg_model_gpu.frag');
  });

  test('F0752SchnakenbergModel presets are well-formed', () {
    final m = F0752SchnakenbergModel();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0752SchnakenbergModel metadata is consistent', () {
    final m = F0752SchnakenbergModel();
    expect(m.metadata.id, m.id);
  });
}

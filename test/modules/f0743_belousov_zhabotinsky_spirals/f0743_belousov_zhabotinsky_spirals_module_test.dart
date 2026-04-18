// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0743_belousov_zhabotinsky_spirals/f0743_belousov_zhabotinsky_spirals_module.dart';

void main() {
  test('F0743BelousovZhabotinskySpirals instantiates', () {
    final m = F0743BelousovZhabotinskySpirals();
    expect(m.id, 'f0743_belousov_zhabotinsky_spirals');
    expect(m.shader, 'shaders/f0743_belousov_zhabotinsky_spirals_gpu.frag');
  });

  test('F0743BelousovZhabotinskySpirals presets are well-formed', () {
    final m = F0743BelousovZhabotinskySpirals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0743BelousovZhabotinskySpirals metadata is consistent', () {
    final m = F0743BelousovZhabotinskySpirals();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0754_meinhardt_seashell/f0754_meinhardt_seashell_module.dart';

void main() {
  test('F0754MeinhardtSeashell instantiates', () {
    final m = F0754MeinhardtSeashell();
    expect(m.id, 'f0754_meinhardt_seashell');
    expect(m.shader, 'shaders/f0754_meinhardt_seashell_gpu.frag');
  });

  test('F0754MeinhardtSeashell presets are well-formed', () {
    final m = F0754MeinhardtSeashell();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0754MeinhardtSeashell metadata is consistent', () {
    final m = F0754MeinhardtSeashell();
    expect(m.metadata.id, m.id);
  });
}

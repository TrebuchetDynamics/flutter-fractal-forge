// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0753_meinhardt_gierer_activator_inhibitor/f0753_meinhardt_gierer_activator_inhibitor_module.dart';

void main() {
  test('F0753MeinhardtGiererActivatorInhibitor instantiates', () {
    final m = F0753MeinhardtGiererActivatorInhibitor();
    expect(m.id, 'f0753_meinhardt_gierer_activator_inhibitor');
    expect(m.shader, 'shaders/f0753_meinhardt_gierer_activator_inhibitor_gpu.frag');
  });

  test('F0753MeinhardtGiererActivatorInhibitor presets are well-formed', () {
    final m = F0753MeinhardtGiererActivatorInhibitor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0753MeinhardtGiererActivatorInhibitor metadata is consistent', () {
    final m = F0753MeinhardtGiererActivatorInhibitor();
    expect(m.metadata.id, m.id);
  });
}

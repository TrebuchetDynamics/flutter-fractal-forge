// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0781_beta_expansion_fractal_phi/f0781_beta_expansion_fractal_phi_module.dart';

void main() {
  test('F0781BetaExpansionFractalPhi instantiates', () {
    final m = F0781BetaExpansionFractalPhi();
    expect(m.id, 'f0781_beta_expansion_fractal_phi');
    expect(m.shader, 'shaders/f0781_beta_expansion_fractal_phi_gpu.frag');
  });

  test('F0781BetaExpansionFractalPhi presets are well-formed', () {
    final m = F0781BetaExpansionFractalPhi();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0781BetaExpansionFractalPhi metadata is consistent', () {
    final m = F0781BetaExpansionFractalPhi();
    expect(m.metadata.id, m.id);
  });
}

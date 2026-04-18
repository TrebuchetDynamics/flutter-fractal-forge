// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0746_fitzhugh_nagumo_spirals/f0746_fitzhugh_nagumo_spirals_module.dart';

void main() {
  test('F0746FitzhughNagumoSpirals instantiates', () {
    final m = F0746FitzhughNagumoSpirals();
    expect(m.id, 'f0746_fitzhugh_nagumo_spirals');
    expect(m.shader, 'shaders/f0746_fitzhugh_nagumo_spirals_gpu.frag');
  });

  test('F0746FitzhughNagumoSpirals presets are well-formed', () {
    final m = F0746FitzhughNagumoSpirals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0746FitzhughNagumoSpirals metadata is consistent', () {
    final m = F0746FitzhughNagumoSpirals();
    expect(m.metadata.id, m.id);
  });
}

// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0745_fitzhugh_nagumo_excitable_medium/f0745_fitzhugh_nagumo_excitable_medium_module.dart';

void main() {
  test('F0745FitzhughNagumoExcitableMedium instantiates', () {
    final m = F0745FitzhughNagumoExcitableMedium();
    expect(m.id, 'f0745_fitzhugh_nagumo_excitable_medium');
    expect(m.shader, 'shaders/f0745_fitzhugh_nagumo_excitable_medium_gpu.frag');
  });

  test('F0745FitzhughNagumoExcitableMedium presets are well-formed', () {
    final m = F0745FitzhughNagumoExcitableMedium();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0745FitzhughNagumoExcitableMedium metadata is consistent', () {
    final m = F0745FitzhughNagumoExcitableMedium();
    expect(m.metadata.id, m.id);
  });
}
